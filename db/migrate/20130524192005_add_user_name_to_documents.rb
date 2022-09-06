class AddUserNameToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :user_name, :string
  end
end
