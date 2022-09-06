class AddFormationToWells < ActiveRecord::Migration
  def change
    add_column :wells, :formation, :string
    add_column :wells, :county, :string
    add_column :wells, :country_id, :integer
    add_column :wells, :state_id, :integer
    add_column :wells, :bottom_hole_location, :string, :limit => 50
  end
end
