class AddDefaultDocumentType < ActiveRecord::Migration
    def change
        change_column :documents, :document_type, :int, default: 0
    end
end
