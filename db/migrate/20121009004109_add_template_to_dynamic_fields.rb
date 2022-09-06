class AddTemplateToDynamicFields < ActiveRecord::Migration
  def change
    add_column :dynamic_fields, :template, :boolean
  end
end
