class AddIndexToCompanyIdInUsers < ActiveRecord::Migration
  def change
      add_index :users, :company_id
  end
end
