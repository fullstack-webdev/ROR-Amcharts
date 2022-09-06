class AddPriorityToDynamicFields < ActiveRecord::Migration
  def change
    add_column :dynamic_fields, :priority, :boolean
  end
end
