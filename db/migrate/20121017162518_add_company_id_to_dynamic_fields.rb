class AddCompanyIdToDynamicFields < ActiveRecord::Migration
  def change
    add_column :dynamic_fields, :company_id, :integer
    add_index :dynamic_fields, :company_id
  end
end
