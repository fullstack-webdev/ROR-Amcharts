class AddDayCostToRigs < ActiveRecord::Migration
  def change
    add_column :rigs, :day_cost, :float
  end
end
