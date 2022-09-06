class CreateWells < ActiveRecord::Migration
  def change
    create_table :wells do |t|
      t.string :name
      t.integer :company_id
      t.integer :field_id

      t.timestamps
    end

    add_index :wells, :company_id
    add_index :wells, :field_id
  end
end
