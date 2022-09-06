class AddDepthFromAndDepthToToCasings < ActiveRecord::Migration
  def change
    add_column :casings, :depth_from, :float
    add_column :casings, :depth_to, :float
  end
end
