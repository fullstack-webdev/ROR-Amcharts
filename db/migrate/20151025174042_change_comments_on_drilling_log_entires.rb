class ChangeCommentsOnDrillingLogEntires < ActiveRecord::Migration
  def change
      change_column :drilling_log_entries, :comment, :string, :limit => 2500
  end
end
