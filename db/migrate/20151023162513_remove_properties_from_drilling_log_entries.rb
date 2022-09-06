class RemovePropertiesFromDrillingLogEntries < ActiveRecord::Migration
    def change

        add_column :drilling_log_entries, :end_time, :datetime
        add_column :drilling_log_entries, :additional, :boolean

        remove_column :drilling_log_entries, :course_length
        remove_column :drilling_log_entries, :rop
        remove_column :drilling_log_entries, :wob
        remove_column :drilling_log_entries, :flow
        remove_column :drilling_log_entries, :rotary_rpm
        remove_column :drilling_log_entries, :motor_rpm
        remove_column :drilling_log_entries, :spp
        remove_column :drilling_log_entries, :torque
        remove_column :drilling_log_entries, :rotary_weight
        remove_column :drilling_log_entries, :pu_weight
        remove_column :drilling_log_entries, :so_weight
        remove_column :drilling_log_entries, :diff_pressure
        remove_column :drilling_log_entries, :stall
        remove_column :drilling_log_entries, :tfo
        remove_column :drilling_log_entries, :mud_type
        remove_column :drilling_log_entries, :mud_weight
        remove_column :drilling_log_entries, :viscosity
        remove_column :drilling_log_entries, :chlorides
        remove_column :drilling_log_entries, :yp
        remove_column :drilling_log_entries, :pv
        remove_column :drilling_log_entries, :ph
        remove_column :drilling_log_entries, :gas
        remove_column :drilling_log_entries, :sand
        remove_column :drilling_log_entries, :solids
        remove_column :drilling_log_entries, :oil
        remove_column :drilling_log_entries, :bh_temp
        remove_column :drilling_log_entries, :fl_temp
        remove_column :drilling_log_entries, :water_loss
        remove_column :drilling_log_entries, :stroke_length
        remove_column :drilling_log_entries, :pump_efficiency
        remove_column :drilling_log_entries, :gallons_stroke
        remove_column :drilling_log_entries, :mwd_type
        remove_column :drilling_log_entries, :em_hertz
        remove_column :drilling_log_entries, :em_cycles
        remove_column :drilling_log_entries, :em_amps
        remove_column :drilling_log_entries, :battery_ahr
        remove_column :drilling_log_entries, :battery_volts
        remove_column :drilling_log_entries, :survey_sequence
        remove_column :drilling_log_entries, :logging_sequence
        remove_column :drilling_log_entries, :pulse_width
        remove_column :drilling_log_entries, :pulse_height
        remove_column :drilling_log_entries, :poppet
        remove_column :drilling_log_entries, :orifice

    end
end
