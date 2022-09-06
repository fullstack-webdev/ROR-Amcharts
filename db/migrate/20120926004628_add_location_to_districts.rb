class AddLocationToDistricts < ActiveRecord::Migration
  def change
    add_column :districts, :location, :string
  end
end
