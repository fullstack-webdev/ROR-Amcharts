class AddTotalTimeToDrillingLogs < ActiveRecord::Migration
  def change
    add_column :drilling_logs, :total_time, :decimal
  end
end
