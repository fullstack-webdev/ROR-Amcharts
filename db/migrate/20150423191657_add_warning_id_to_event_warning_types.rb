class AddWarningIdToEventWarningTypes < ActiveRecord::Migration
  def change
    add_column :event_warning_types, :warning_id, :string, unique: true
  end
end
