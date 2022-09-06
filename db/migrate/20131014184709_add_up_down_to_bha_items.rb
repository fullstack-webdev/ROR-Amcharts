class AddUpDownToBhaItems < ActiveRecord::Migration
  def change
    add_column :bha_items, :up, :integer
    add_column :bha_items, :down, :integer
  end
end
