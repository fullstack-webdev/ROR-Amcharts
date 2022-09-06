class CreateFields < ActiveRecord::Migration
  def change
    create_table :fields do |t|
      t.string :name
      t.integer :company_id
      t.integer :district_id

      t.timestamps
    end

    add_index :fields, :company_id
    add_index :fields, :district_id
  end
end
