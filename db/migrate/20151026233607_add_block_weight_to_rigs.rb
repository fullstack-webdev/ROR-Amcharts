class AddBlockWeightToRigs < ActiveRecord::Migration
  def change
    add_column :rigs, :block_weight, :decimal
  end
end
