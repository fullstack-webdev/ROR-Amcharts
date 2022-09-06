class AddRigIdToWells < ActiveRecord::Migration
  def change
    add_column :wells, :rig_id, :integer
  end
end
