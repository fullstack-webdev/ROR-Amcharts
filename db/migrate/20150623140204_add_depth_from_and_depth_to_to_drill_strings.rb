class AddDepthFromAndDepthToToDrillStrings < ActiveRecord::Migration
  def change
    add_column :drilling_strings, :depth_from, :float
    add_column :drilling_strings, :depth_to, :float
  end
end
