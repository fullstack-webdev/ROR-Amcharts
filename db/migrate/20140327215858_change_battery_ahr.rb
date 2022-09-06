class ChangeBatteryAhr < ActiveRecord::Migration
  def change
      rename_column :drilling_log_entries, :battery_1_ahr, :battery_ahr

      remove_column :drilling_log_entries, :battery_1_amps
      remove_column :drilling_log_entries, :battery_2_ahr
      remove_column :drilling_log_entries, :battery_2_amps
  end
end
