class RenameOrderToOrderingOnDynamicFields < ActiveRecord::Migration
  def up
      rename_column :dynamic_fields, :order, :ordering
  end

  def down
  end
end
