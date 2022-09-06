class AddExternalUserToJobMemberships < ActiveRecord::Migration
  def change
    add_column :job_memberships, :external_user, :boolean, :default => false
  end
end
