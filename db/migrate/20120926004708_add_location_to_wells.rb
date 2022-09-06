class AddLocationToWells < ActiveRecord::Migration
  def change
    add_column :fields, :location, :string
  end
end
