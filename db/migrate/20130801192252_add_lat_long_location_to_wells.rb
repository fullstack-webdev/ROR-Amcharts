class AddLatLongLocationToWells < ActiveRecord::Migration
    def change
        add_column :wells, :location, :string, :limit => 50
    end
end
