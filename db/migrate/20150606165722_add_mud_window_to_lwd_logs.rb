class AddMudWindowToLwdLogs < ActiveRecord::Migration
    def change
        add_column :lwd_logs, :emw_pore_pressure, :float
        add_column :lwd_logs, :emw_shear_failure, :float
        add_column :lwd_logs, :emw_min_stress, :float
        add_column :lwd_logs, :emw_fracture_pressure, :float
    end
end
