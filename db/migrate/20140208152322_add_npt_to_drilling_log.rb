class AddNptToDrillingLog < ActiveRecord::Migration
    def change
        add_column :drilling_logs, :npt, :decimal, :default => 0.0
    end
end
