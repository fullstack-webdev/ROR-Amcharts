class AddPrimaryToolIdToDocuments < ActiveRecord::Migration
    def change
        add_column :documents, :primary_tool_id, :integer
        add_index :documents, :primary_tool_id
    end
end
