class AddDepthToBits < ActiveRecord::Migration
  def change
    add_column :bits, :depth_from, :float
    add_column :bits, :depth_to, :float
  end
end
