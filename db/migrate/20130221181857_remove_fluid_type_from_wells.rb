class RemoveFluidTypeFromWells < ActiveRecord::Migration
  def change
      remove_column :wells, :fuild_type
      remove_column :wells, :fluid_weight
  end
end
