class UpdateWells < ActiveRecord::Migration
  def change
    remove_column :wells, :rig_name
    remove_column :wells, :datum
    remove_column :wells, :measured_depth
    remove_column :wells, :measured_depth_value_type
    remove_column :wells, :true_vertical_depth
    remove_column :wells, :true_vertical_depth_value_type
    remove_column :wells, :water_depth
    remove_column :wells, :water_depth_value_type
    remove_column :wells, :offshore
    remove_column :wells, :bottom_hole_temperature
    remove_column :wells, :bottom_hole_temperature_value_type
    remove_column :wells, :bottom_hole_formation_pressure
    remove_column :wells, :bottom_hole_formation_pressure_value_type
    remove_column :wells, :frac_pressure
    remove_column :wells, :frac_pressure_value_type
    remove_column :wells, :max_deviation
    remove_column :wells, :bottom_deviation
    remove_column :wells, :formation

    add_column :wells, :hole_depth, :float
    add_column :wells, :total_time, :integer
    add_column :wells, :total_time_morning, :integer
    add_column :wells, :total_time_night, :integer
    add_column :wells, :drilling_rop, :float
    add_column :wells, :potential_savings, :float
    add_column :wells, :histogram, :text
  end
end
