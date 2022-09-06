class AddDocumentTemplatesModifyToUserRoles < ActiveRecord::Migration
  def change
    add_column :user_roles, :document_templates_modify, :boolean, :default => false
  end
end
