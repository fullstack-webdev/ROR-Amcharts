class AddWellIdToDrillingLogs < ActiveRecord::Migration
  def change
    add_column :drilling_logs, :well_id, :integer
  end
end
