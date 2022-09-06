class AddEntryTimeToJobLogs < ActiveRecord::Migration
  def change
    add_column :job_logs, :entry_at, :datetime
  end
end
