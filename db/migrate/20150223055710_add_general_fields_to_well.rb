class AddGeneralFieldsToWell < ActiveRecord::Migration
  def change
    add_column :wells, :county, :string
    add_column :wells, :drilling_company, :string
    add_column :wells, :fluid_company, :string
    add_column :wells, :well_number, :string
    add_column :wells, :api_number, :string
  end
end
