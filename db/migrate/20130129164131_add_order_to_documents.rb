class AddOrderToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :order, :integer
  end
end
