class AddInventoryNotesToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :inventory_notes, :string, :limit => 500
  end
end
