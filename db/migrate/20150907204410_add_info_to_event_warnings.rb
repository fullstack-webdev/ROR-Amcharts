class AddInfoToEventWarnings < ActiveRecord::Migration
  def change
    add_column :event_warnings, :info, :text
  end
end
