class AddPropertiesToDrillingLogEntry < ActiveRecord::Migration
    def change
        add_column :drilling_log_entries, :rotary_weight, :decimal
        add_column :drilling_log_entries, :pu_weight, :decimal
        add_column :drilling_log_entries, :so_weight, :decimal
        add_column :drilling_log_entries, :diff_pressure, :decimal
        add_column :drilling_log_entries, :stall, :decimal
        add_column :drilling_log_entries, :tfo, :decimal

        add_column :drilling_log_entries, :mud_type, :integer
        add_column :drilling_log_entries, :mud_weight, :decimal
        add_column :drilling_log_entries, :viscosity, :decimal
        add_column :drilling_log_entries, :chlorides, :decimal
        add_column :drilling_log_entries, :yp, :decimal
        add_column :drilling_log_entries, :pv, :decimal
        add_column :drilling_log_entries, :ph, :decimal
        add_column :drilling_log_entries, :gas, :decimal
        add_column :drilling_log_entries, :sand, :decimal
        add_column :drilling_log_entries, :solids, :decimal
        add_column :drilling_log_entries, :oil, :decimal
        add_column :drilling_log_entries, :bh_temp, :decimal
        add_column :drilling_log_entries, :fl_temp, :decimal
        add_column :drilling_log_entries, :water_loss, :decimal


        add_column :drilling_log_entries, :battery_1_amps, :decimal
        add_column :drilling_log_entries, :battery_2_amps, :decimal
        add_column :drilling_log_entries, :battery_volts, :decimal

    end
end
