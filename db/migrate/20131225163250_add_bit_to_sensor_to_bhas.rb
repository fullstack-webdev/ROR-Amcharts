class AddBitToSensorToBhas < ActiveRecord::Migration
  def change
    add_column :bhas, :bit_to_sensor, :decimal
    add_column :bhas, :bit_to_gamma, :decimal

    add_column :bhas, :bit_type, :integer
    add_column :bhas, :bit_jets, :string
    add_column :bhas, :bit_tfa, :decimal
    add_column :bhas, :bit_size, :decimal

  end
end
