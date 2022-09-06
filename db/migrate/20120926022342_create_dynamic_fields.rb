class CreateDynamicFields < ActiveRecord::Migration
  def change
    create_table :dynamic_fields do |t|
      t.integer :job_template_id
      t.integer :job_id
      t.string :name, :null => false
      t.string :value
      t.string :value_type_conversion, :default => 'to_s'

      t.timestamps
    end

    add_index :dynamic_fields, :job_template_id
    add_index :dynamic_fields, :job_id
    add_index :dynamic_fields, :name
  end
end
