class CreateUserRoles < ActiveRecord::Migration
    def change
        create_table :user_roles do |t|
            t.string :title
            t.integer :company_id
            t.boolean :create_job, default: false
            t.boolean :assign_users, default: false
            t.boolean :district_read, default: false
            t.boolean :district_modify, default: false
            t.boolean :product_line_read, default: false
            t.boolean :product_line_modify, default: false
            t.boolean :global_read, default: false
            t.boolean :global_modify, default: false

            t.timestamps
        end

        add_index :user_roles, :company_id
    end
end
