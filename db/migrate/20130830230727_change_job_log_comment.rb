class ChangeJobLogComment < ActiveRecord::Migration
  def change
      change_column :job_logs, :comment, :string, :limit => 500
  end
end
