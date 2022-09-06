class AddDrillingTimeToDrillingLogs < ActiveRecord::Migration
    def change
        add_column :drilling_logs, :drilling_time, :decimal
        add_column :drilling_logs, :total_circulation_time, :decimal
    end
end
