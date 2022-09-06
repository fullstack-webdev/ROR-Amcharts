class AddDefaultValueTypeToDynamicFields < ActiveRecord::Migration
  def change
    add_column :dynamic_fields, :default_value_type, :integer, :default => 0
  end
end
