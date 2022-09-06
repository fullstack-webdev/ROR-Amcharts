class RenameCreatedByOnAlerts < ActiveRecord::Migration
  def up
      rename_column :alerts, :created_by, :created_by_id
  end

  def down
  end
end
