class RenameOrderToOrderingOnDocuments < ActiveRecord::Migration
  def up
      rename_column :documents, :order, :ordering
  end

  def down
  end
end
