class CreateJobLogs < ActiveRecord::Migration
  def change
    create_table :job_logs do |t|
      t.integer :company_id
      t.integer :document_id
      t.integer :job_id
      t.integer :user_id
      t.string :comment

      t.timestamps
    end
  end
end
