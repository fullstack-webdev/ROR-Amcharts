class AddPulseWidthToDrillingLogEntries < ActiveRecord::Migration
    def change
        add_column :drilling_log_entries, :survey_sequence, :string
        add_column :drilling_log_entries, :logging_sequence, :string
        add_column :drilling_log_entries, :pulse_width, :decimal
        add_column :drilling_log_entries, :pulse_height, :decimal
        add_column :drilling_log_entries, :poppet, :decimal
        add_column :drilling_log_entries, :orifice, :decimal
    end
end
