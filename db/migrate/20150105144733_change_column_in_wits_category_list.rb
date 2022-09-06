class ChangeColumnInWitsCategoryList < ActiveRecord::Migration
  def change
    remove_column :wits_category_lists, :category_name
    add_column :wits_category_lists, :category_name, :integer
  end

end
