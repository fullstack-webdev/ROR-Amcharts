class CreateRigs < ActiveRecord::Migration
  def change
    create_table :rigs do |t|
      t.integer :company_id
      t.string :name

      t.timestamps
    end
  end
end
