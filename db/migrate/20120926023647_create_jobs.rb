class CreateJobs < ActiveRecord::Migration
    def change
        create_table :jobs do |t|
            t.integer :job_template_id
            t.integer :field_id
            t.integer :well_id
            t.integer :district_id
            t.integer :client_id
            t.string :client_contact_name
            t.datetime :start_date
            t.datetime :end_date
            t.integer :district_manager_id
            t.integer :sales_engineer_id

            t.timestamps
        end

        add_index :jobs, :job_template_id
        add_index :jobs, :field_id
        add_index :jobs, :well_id
        add_index :jobs, :district_id
        add_index :jobs, :client_id
    end
end
