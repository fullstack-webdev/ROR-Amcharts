class AddTdDepthToDrillingLogs < ActiveRecord::Migration
    def change
        add_column :drilling_logs, :td_depth, :decimal, :default => 0.0
    end
end
