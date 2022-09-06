class AddColumnToWells < ActiveRecord::Migration
  def change
    add_column :wells, :started_at, :datetime
    add_column :wells, :warnings_by_depth, :text
    add_column :wells, :depth_vs_time_logs, :text
    add_column :wells, :depth_vs_warnings_logs, :text
    add_column :wells, :footage_logs, :text
    add_column :wells, :depth_vs_cost_logs, :text
  end
end
