class AddDefaultToConfigurations < ActiveRecord::Migration
  def change
    add_column :bits, :default, :boolean, :null => false, :default => false
    add_column :casings, :default, :boolean, :null => false, :default => false
    add_column :drilling_strings, :default, :boolean, :null => false, :default => false
    add_column :hole_sizes, :default, :boolean, :null => false, :default => false
    add_column :fluids, :default, :boolean, :null => false, :default => false
  end
end
