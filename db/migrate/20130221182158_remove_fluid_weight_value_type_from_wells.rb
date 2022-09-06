class RemoveFluidWeightValueTypeFromWells < ActiveRecord::Migration
  def change
      remove_column :wells, :fluid_weight_value_type


  end

end
