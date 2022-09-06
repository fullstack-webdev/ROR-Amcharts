class AddWarningFamilyAndCategoryToEventWarnings < ActiveRecord::Migration
  def change
    add_column :event_warnings, :warning_family, :integer
    add_column :event_warnings, :warning_category, :integer
    add_column :event_warnings, :depth, :float
  end
end
