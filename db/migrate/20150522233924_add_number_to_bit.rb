class AddNumberToBit < ActiveRecord::Migration
  def change
    add_column :bits, :number, :int
    add_column :bits, :in_depth, :float
  end
end
