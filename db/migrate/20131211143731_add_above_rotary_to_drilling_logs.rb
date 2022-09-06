class AddAboveRotaryToDrillingLogs < ActiveRecord::Migration
  def change
    add_column :drilling_logs, :above_rotary, :decimal
  end
end
