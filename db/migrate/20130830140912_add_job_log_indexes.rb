class AddJobLogIndexes < ActiveRecord::Migration
    def change
        add_index :job_logs, :company_id
        add_index :job_logs, :document_id
        add_index :job_logs, :job_id
        add_index :job_logs, :user_id
    end
end
