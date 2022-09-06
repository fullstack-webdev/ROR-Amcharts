class AddOrderToDynamicFields < ActiveRecord::Migration
  def change
    add_column :dynamic_fields, :order, :integer, :default => 0
  end
end
