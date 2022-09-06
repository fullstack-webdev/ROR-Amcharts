class AddUserNameToJobMemberships < ActiveRecord::Migration
  def change
    add_column :job_memberships, :user_name, :string
  end
end
