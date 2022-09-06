class AddBitDepthToWitsGactivities < ActiveRecord::Migration
  def change
    add_column :wits_gactivities, :bit_depth, :float
  end
end
