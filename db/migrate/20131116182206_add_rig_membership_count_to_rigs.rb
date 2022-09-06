class AddRigMembershipCountToRigs < ActiveRecord::Migration
  def change
      add_column :rigs, :rig_memberships_count, :integer, :default => 0
  end
end
