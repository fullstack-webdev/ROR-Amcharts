class AddMasterDistrictIdToDistricts < ActiveRecord::Migration
    def change
        add_column :districts, :master_district_id, :integer
        add_column :districts, :master, :boolean, :default => true

        add_index :districts, :master_district_id
    end
end
