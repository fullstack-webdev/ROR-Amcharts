class SetDocumentOrderDefaultOnDocuments < ActiveRecord::Migration
  def change
      change_column :documents, :order, :integer, :default => 0
  end
end
