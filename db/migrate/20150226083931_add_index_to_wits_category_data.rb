class AddIndexToWitsCategoryData < ActiveRecord::Migration
  def change
    add_index :wits_category_data, :entry_at
  end
end
