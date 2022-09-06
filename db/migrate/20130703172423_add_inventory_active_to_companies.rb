class AddInventoryActiveToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :inventory_active, :boolean, :default => true
  end
end
