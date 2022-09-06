class AddDocumentTemplateIdToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :document_template_id, :integer
    add_index :documents, :document_template_id
  end
end
