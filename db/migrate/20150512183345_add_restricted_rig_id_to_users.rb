class AddRestrictedRigIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :restricted_rig_id, :integer
    add_index :users, :restricted_rig_id
  end
end
