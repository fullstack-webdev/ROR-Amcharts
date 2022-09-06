class AddPredefinedToDynamicFields < ActiveRecord::Migration
  def change
    add_column :dynamic_fields, :predefined, :boolean, :default => false
  end
end
