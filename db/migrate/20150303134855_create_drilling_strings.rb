class CreateDrillingStrings < ActiveRecord::Migration
  def change
    create_table :drilling_strings do |t|
      t.belongs_to :company
      t.belongs_to :job
      t.string :type
      t.float :outer_diameter
      t.float :inner_diameter
      t.float :weight
      t.float :length
      t.datetime :entry_at
      t.timestamps
    end

    add_index :drilling_strings, :company_id
    add_index :drilling_strings, :job_id
    add_index :drilling_strings, :entry_at
  end
end
