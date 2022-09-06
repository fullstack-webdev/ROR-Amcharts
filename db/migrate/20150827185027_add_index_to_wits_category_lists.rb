class AddIndexToWitsCategoryLists < ActiveRecord::Migration
  def change
    add_index :wits_category_lists, :operation_time
  end
end
