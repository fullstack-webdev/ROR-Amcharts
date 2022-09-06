class RemoveIndexJobMembershipsOnUserIdAndJobIdFromJobMemberships < ActiveRecord::Migration
  def up
      remove_index "job_memberships", :name => "index_job_memberships_on_user_id_and_job_id"
  end

  def down
  end
end
