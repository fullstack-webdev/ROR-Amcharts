class AddInventoryConfirmedToJobs < ActiveRecord::Migration
    def change
        add_column :jobs, :inventory_confirmed, :boolean, :default => false
    end
end
