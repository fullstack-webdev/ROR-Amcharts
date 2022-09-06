class AddJobRoleIdToJobMemberships < ActiveRecord::Migration
  def change
    add_column :job_memberships, :job_role_id, :integer
  end
end
