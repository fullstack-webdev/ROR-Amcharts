class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.boolean :admin
      t.boolean :create_access
      t.boolean :write_access
      t.integer :company_id
      t.integer :district_id
      t.string :location
      t.string :position_title
      t.string :phone_number

      t.timestamps
    end
  end
end
