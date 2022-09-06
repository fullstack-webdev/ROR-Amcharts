class AddUserNameToJobLogs < ActiveRecord::Migration
  def change
    add_column :job_logs, :user_name, :string
  end
end
