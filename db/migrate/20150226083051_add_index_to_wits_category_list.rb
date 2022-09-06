class AddIndexToWitsCategoryList < ActiveRecord::Migration
  def change
    add_index :wits_category_lists, :company_id
    add_index :wits_category_lists, :job_id
    add_index :wits_category_lists, :time_stamp
  end
end
