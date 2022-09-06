class AddWobToDrillingLogEntries < ActiveRecord::Migration
  def change
    add_column :drilling_log_entries, :wob, :decimal
    add_column :drilling_log_entries, :flow, :decimal
    add_column :drilling_log_entries, :rotary_rpm, :decimal
    add_column :drilling_log_entries, :motor_rpm, :decimal
    add_column :drilling_log_entries, :spp, :decimal
    add_column :drilling_log_entries, :torque, :decimal
  end
end
