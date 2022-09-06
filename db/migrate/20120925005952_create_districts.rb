class CreateDistricts < ActiveRecord::Migration
  def change
    create_table :districts do |t|
      t.string :name
      t.integer :company_id

      t.timestamps
    end

    add_index :districts, :company_id
  end
end
