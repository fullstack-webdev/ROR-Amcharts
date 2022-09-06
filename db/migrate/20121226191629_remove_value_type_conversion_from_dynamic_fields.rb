class RemoveValueTypeConversionFromDynamicFields < ActiveRecord::Migration
  def up
      remove_column :dynamic_fields, :value_type_conversion

      add_column :dynamic_fields, :value_type, :integer, :default => 1
  end

  def down
  end
end
