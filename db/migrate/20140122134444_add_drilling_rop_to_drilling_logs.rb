class AddDrillingRopToDrillingLogs < ActiveRecord::Migration
    def change
        add_column :drilling_logs, :drilling_rop, :decimal, :default => 0.0
    end
end
