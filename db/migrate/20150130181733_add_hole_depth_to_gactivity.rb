class AddHoleDepthToGactivity < ActiveRecord::Migration
  def change
    add_column :wits_gactivities, :hole_depth, :float
  end
end
