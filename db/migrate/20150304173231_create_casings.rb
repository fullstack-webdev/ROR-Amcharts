class CreateCasings < ActiveRecord::Migration
  def change
    create_table :casings do |t|
      t.belongs_to :company
      t.belongs_to :job
      t.float :inner_diameter
      t.float :length
      t.datetime :entry_at
      t.timestamps
    end

    add_index :casings, :company_id
    add_index :casings, :job_id
    add_index :casings, :entry_at
  end
end
