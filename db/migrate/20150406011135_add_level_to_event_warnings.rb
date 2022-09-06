class AddLevelToEventWarnings < ActiveRecord::Migration
  def change
    add_column :event_warnings, :level, :integer, :default => 1
  end
end
