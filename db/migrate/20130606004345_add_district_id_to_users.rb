class AddDistrictIdToUsers < ActiveRecord::Migration
    def change
        add_column :users, :division_id, :integer
        add_column :users, :segment_id, :integer
    end
end
