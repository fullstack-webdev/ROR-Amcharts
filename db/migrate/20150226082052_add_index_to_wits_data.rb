class AddIndexToWitsData < ActiveRecord::Migration
  def change
    add_index :wits_data, :job_id
    add_index :wits_data, :company_id
    add_index :wits_data, :entry_at
  end
end
