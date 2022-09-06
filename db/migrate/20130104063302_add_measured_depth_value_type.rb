class AddMeasuredDepthValueType < ActiveRecord::Migration
  def up
      add_column :wells, :measured_depth_value_type, :integer, :default => 1
      add_column :wells, :true_vertical_depth_value_type, :integer, :default => 1
      add_column :wells, :water_depth_value_type, :integer, :default => 1
      add_column :wells, :bottom_hole_temperature_value_type, :integer, :default => 1
      add_column :wells, :bottom_hole_formation_pressure_value_type, :integer, :default => 1
      add_column :wells, :frac_pressure_value_type, :integer, :default => 1
      add_column :wells, :fluid_weight_value_type, :integer, :default => 1
  end

  def down
  end
end
