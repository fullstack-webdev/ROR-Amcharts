class AddMeasuredDepthToWells < ActiveRecord::Migration
  def change
    add_column :wells, :measured_depth, :float
    add_column :wells, :true_vertical_depth, :float
    add_column :wells, :water_depth, :float
    add_column :wells, :offshore, :boolean, default: false
    add_column :wells, :bottom_hole_temperature, :float
    add_column :wells, :bottom_hole_formation_pressure, :float
    add_column :wells, :frac_pressure, :float
    add_column :wells, :fuild_type, :string
    add_column :wells, :fluid_weight, :float
    add_column :wells, :max_deviation, :float
    add_column :wells, :bottom_deviation, :float
    add_column :wells, :rig_name, :string
  end
end
