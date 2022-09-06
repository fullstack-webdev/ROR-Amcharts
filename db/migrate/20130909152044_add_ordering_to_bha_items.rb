class AddOrderingToBhaItems < ActiveRecord::Migration
  def change
    add_column :bha_items, :ordering, :integer
  end
end
