class AddActivityIdToWarnings < ActiveRecord::Migration
  def change
    add_column :event_warnings, :activity_id, :integer
  end
end
