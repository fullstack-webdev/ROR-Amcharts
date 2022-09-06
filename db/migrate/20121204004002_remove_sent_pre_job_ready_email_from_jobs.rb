class RemoveSentPreJobReadyEmailFromJobs < ActiveRecord::Migration
  def up
      remove_column :jobs, :sent_pre_job_ready_email
  end

  def down
  end
end
