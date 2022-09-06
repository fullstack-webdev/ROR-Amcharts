class RenameIsToolOnDynamicFields < ActiveRecord::Migration
  def up
      rename_column :dynamic_fields, :is_tool, :optional
  end

  def down
  end
end
