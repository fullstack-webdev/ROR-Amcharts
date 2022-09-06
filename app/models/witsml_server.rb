require 'uri'
require 'net/http'
require 'net/https'

class WitsmlServer < ActiveRecord::Base
    attr_accessible :location
    attr_encrypted :username, :key => 'username'
    attr_encrypted :password, :key => 'password'

    acts_as_tenant(:company)

    belongs_to :company

    def name
        uri = URI(self.location)
        if uri.host.ends_with? "welldata.net"
            return "NOV"
        end

        parts = uri.host.split(".")
        if parts.length == 2
            return parts[0].capitalize
        else
            return parts[1].capitalize
        end
    end

    def get_state
        begin
            uri = URI('https://52.5.233.28/api/WitsmlServerState')
            https = Net::HTTP.new(uri.host, uri.port)
            https.use_ssl = true
            https.verify_mode = OpenSSL::SSL::VERIFY_NONE
            req = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json'})
            req['Auth-Token'] = '4aa9d0d9-f9c5-4f7d-9811-5dfc5ddbf9a9'
            req.body = {Url: self.location, User: self.username, Password: self.password}.to_json
            res = https.request(req)
            return res.body.to_s
        rescue => e
            puts e.message
            return nil
        end
    end

    def get_well_list
        begin
            uri = URI('https://52.5.233.28/api/WitsmlServerHierarchy')
            https = Net::HTTP.new(uri.host, uri.port)
            https.use_ssl = true
            https.verify_mode = OpenSSL::SSL::VERIFY_NONE
            req = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json'})
            req['Auth-Token'] = '4aa9d0d9-f9c5-4f7d-9811-5dfc5ddbf9a9'
            req.body = {Url: self.location, User: self.username, Password: self.password}.to_json
            res = https.request(req)
            return res.body.to_s
        rescue => e
            puts e.message
            return nil
        end
    end

    def connected?
        state = JSON.parse(get_state)["IsOnline"]
        return state == true
    end

    def import_well job, well_id, wellbore_id, log_id
        begin
            uri = URI('https://52.5.233.28/api/WitsmlLogUpload')
            https = Net::HTTP.new(uri.host, uri.port)
            https.use_ssl = true
            https.verify_mode = OpenSSL::SSL::VERIFY_NONE
            req = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json'})
            req['Auth-Token'] = '4aa9d0d9-f9c5-4f7d-9811-5dfc5ddbf9a9'

            req.body = {
                    ServerUrl: self.location,
                    ServerUser: self.username,
                    ServerPassword: self.password,
                    JobId: job.id,
                    CompanyId: self.company.id,
                    WellId: well_id,
                    WellboreId: wellbore_id,
                    LogId: log_id,
                    IsGrowing: false
                    }.to_json

            res = https.request(req)
            return res.body.to_s
        rescue => e
            puts e.message
            return nil
        end

    end

end
