class AddPartRedressIdToDocuments < ActiveRecord::Migration
  def change
      add_column :documents, :owner_id, :integer
      add_column :documents, :owner_type, :string
      add_index :documents, [:owner_id, :owner_type]
  end
end
