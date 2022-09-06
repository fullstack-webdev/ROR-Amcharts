class ReplaceDepthToEventWarnings < ActiveRecord::Migration
  def change
    remove_column :event_warnings, :depth

    add_column :event_warnings, :depth_from, :float
    add_column :event_warnings, :depth_to, :float
  end
end
