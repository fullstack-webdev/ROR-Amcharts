class AddValuesToDynamicFields < ActiveRecord::Migration
  def change
    add_column :dynamic_fields, :values, :string
  end
end
