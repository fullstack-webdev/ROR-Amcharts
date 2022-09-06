class CreateDrillingLogs < ActiveRecord::Migration
    def change
        create_table :drilling_logs do |t|
            t.integer :company_id
            t.integer :document_id
            t.integer :job_id
            t.integer :user_id
            t.string :user_name
            t.datetime :entry_at
            t.decimal :depth
            t.integer :activity_code
            t.string :comment
            t.integer :bha_id
            t.decimal :usage_hours

            t.timestamps
        end

        add_index :drilling_logs, :company_id
        add_index :drilling_logs, :document_id
        add_index :drilling_logs, :job_id
        add_index :drilling_logs, :user_id
        add_index :drilling_logs, :bha_id
    end
end
