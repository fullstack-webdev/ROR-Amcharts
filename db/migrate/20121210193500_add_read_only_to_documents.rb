class AddReadOnlyToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :read_only, :boolean, default: false
  end
end
