class AddDynamicFieldTemplateIdToDynamicFields < ActiveRecord::Migration
  def change
    add_column :dynamic_fields, :dynamic_field_template_id, :integer
    add_index :dynamic_fields, :dynamic_field_template_id
  end
end
