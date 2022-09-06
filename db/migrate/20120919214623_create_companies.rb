class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :name
      t.string :website
      t.string :support_email
      t.string :phone_number
      t.string :address_line_1
      t.string :address_line_2
      t.string :postal_code
      t.string :state
      t.string :country
      t.integer :admin_id
      t.string :logo
      t.string :logo_large

      t.timestamps
    end
  end
end
