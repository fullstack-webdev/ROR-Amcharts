class AddDepthsFieldsToWitsActivityList < ActiveRecord::Migration
  def change
    add_column :wits_activity_lists, :hole_depth, :float
    add_column :wits_activity_lists, :hole_depth_change, :float
    add_column :wits_activity_lists, :bit_depth, :float
    add_column :wits_activity_lists, :bit_depth_change, :float
  end
end
