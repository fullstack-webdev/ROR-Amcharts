class CreateJobProcesses < ActiveRecord::Migration
    def change
        create_table :job_processes do |t|
            t.integer :job_id
            t.integer :company_id
            t.integer :event_type
            t.integer :user_id

            t.timestamps
        end

        add_index :job_processes, :job_id
        add_index :job_processes, :company_id
        add_index :job_processes, :user_id
    end
end
