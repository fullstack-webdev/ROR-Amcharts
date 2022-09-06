class AddSentPreJobReadyEmailToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :sent_pre_job_ready_email, :boolean, default: false
  end
end
