class AddParametersToDrillingLogEntries < ActiveRecord::Migration
    def change
        add_column :drilling_log_entries, :stroke_length, :decimal
        add_column :drilling_log_entries, :pump_efficiency, :decimal
        add_column :drilling_log_entries, :gallons_stroke, :decimal
        add_column :drilling_log_entries, :casing_size, :decimal
        add_column :drilling_log_entries, :mwd_type, :integer, :default => 1
        add_column :drilling_log_entries, :em_hertz, :decimal
        add_column :drilling_log_entries, :em_cycles, :decimal
        add_column :drilling_log_entries, :em_amps, :decimal
        add_column :drilling_log_entries, :battery_1_ahr, :decimal
        add_column :drilling_log_entries, :battery_2_ahr, :decimal
    end
end
