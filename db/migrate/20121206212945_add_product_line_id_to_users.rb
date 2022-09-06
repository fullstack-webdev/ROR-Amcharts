class AddProductLineIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :product_line_id, :integer
  end
end
