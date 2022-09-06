module ActiveRecordExtensions
    class Shard < ActiveRecord::Base
        primary_database_url = ENV['WITS_DATABASE_URL']

        if(!primary_database_url.nil?)
            parsed_connection_string = primary_database_url.split("://")
            adapter = parsed_connection_string[0]
            parsed_connection_string = parsed_connection_string[1].split(":")
            username = parsed_connection_string[0]
            parsed_connection_string = parsed_connection_string[1].split("@")
            password = parsed_connection_string[0]
            parsed_connection_string = parsed_connection_string[1].split("/")
            host = parsed_connection_string[0]
            database = parsed_connection_string[1]

            establish_connection(
                    :adapter  => adapter,
                    :host     => host,
                    :username => username,
                    :password => password,
                    :database => database,
                    :port     => 3306,
                    :pool     => 5,
                    :timeout  => 5000
            )
        else
            self.establish_connection "shard_#{Rails.env}"
        end
    end

    class ShardMigration < ActiveRecord::Migration
        def connection
            ActiveRecord::Shard.connection
        end
    end
end