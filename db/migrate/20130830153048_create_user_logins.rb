class CreateUserLogins < ActiveRecord::Migration
    def change
        create_table :user_logins do |t|
            t.integer :company_id
            t.integer :user_id
            t.string :ip_address, :limit => 200

            t.timestamps
        end

        add_index :user_logins, :company_id
        add_index :user_logins, :user_id
    end
end
