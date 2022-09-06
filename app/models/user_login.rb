class UserLogin < ActiveRecord::Base
    attr_accessible :ip_address

    validates_presence_of :company
    validates_presence_of :user

    belongs_to :company
    belongs_to :user


    def self.add(user, ip_address)
        return false if user.nil? || user.company.nil?

        login = UserLogin.new
        login.user = user
        login.ip_address = ip_address
        login.company = user.company

        login.save!
        login
    end

end
