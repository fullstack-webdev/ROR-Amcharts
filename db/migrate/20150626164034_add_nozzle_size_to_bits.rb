class AddNozzleSizeToBits < ActiveRecord::Migration
  def change
    add_column :bits, :nozzle_size, :float
    add_column :bits, :bit_number, :integer
  end
end
