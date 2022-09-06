class AddIndexToWitsCategoryAlloc < ActiveRecord::Migration
  def change
    add_index :wits_category_allocs, :company_id
    add_index :wits_category_allocs, :job_id
    add_index :wits_category_allocs, :entry_at
  end
end
