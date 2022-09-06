class AddInfoToDistricts < ActiveRecord::Migration
  def change
    add_column :districts, :address_line_1, :string
    add_column :districts, :address_line_2, :string
    add_column :districts, :postal_code, :string
    add_column :districts, :phone_number, :string
    add_column :districts, :city, :string
    add_column :districts, :region, :string
    add_column :districts, :support_email, :string
  end
end
