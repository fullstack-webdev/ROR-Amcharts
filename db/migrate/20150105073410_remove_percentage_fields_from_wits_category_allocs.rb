class RemovePercentageFieldsFromWitsCategoryAllocs < ActiveRecord::Migration
  def change
    remove_column :wits_category_allocs, :reaming_in_per
    remove_column :wits_category_allocs, :reaming_out_per
    remove_column :wits_category_allocs, :reaming_per
    remove_column :wits_category_allocs, :wash_up_per
    remove_column :wits_category_allocs, :wash_down_per
    remove_column :wits_category_allocs, :washing_per
    remove_column :wits_category_allocs, :circulation_per
    remove_column :wits_category_allocs, :drilling_per
    remove_column :wits_category_allocs, :connection_per
    remove_column :wits_category_allocs, :tripping_out_per
    remove_column :wits_category_allocs, :tripping_in_per
    remove_column :wits_category_allocs, :out_of_hole_per
    remove_column :wits_category_allocs, :other_per
  end
end
