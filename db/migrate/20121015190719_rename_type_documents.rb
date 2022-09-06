class RenameTypeDocuments < ActiveRecord::Migration
  def change
      rename_column :documents, :type, :document_type
  end

end
