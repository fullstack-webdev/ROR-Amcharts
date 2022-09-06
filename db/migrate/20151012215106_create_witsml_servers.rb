class CreateWitsmlServers < ActiveRecord::Migration
    def change
        create_table :witsml_servers do |t|

            t.integer :company_id
            t.integer :job_id

            t.string :location
            t.string :encrypted_username
            t.string :encrypted_password

            t.timestamps
        end

        add_index :witsml_servers, :company_id
        add_index :witsml_servers, :job_id
    end
end
