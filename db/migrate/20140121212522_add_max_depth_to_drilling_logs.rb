class AddMaxDepthToDrillingLogs < ActiveRecord::Migration
  def change
    add_column :drilling_logs, :max_depth, :decimal, :default => 0.0
  end
end
