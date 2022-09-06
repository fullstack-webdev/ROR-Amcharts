class UpdateEventWarning < ActiveRecord::Migration
  def change
    remove_column :event_warnings, :warning_type
    remove_column :event_warnings, :warning_family
    remove_column :event_warnings, :warning_category
    remove_column :event_warnings, :level
    add_column :event_warnings, :event_warning_type_id, :integer
    add_index :event_warnings, :event_warning_type_id
  end
end
