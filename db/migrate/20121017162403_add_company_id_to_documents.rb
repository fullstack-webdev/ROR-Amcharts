class AddCompanyIdToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :company_id, :integer
    add_index :documents, :company_id
  end
end
