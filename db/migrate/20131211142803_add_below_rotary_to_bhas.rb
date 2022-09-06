class AddBelowRotaryToBhas < ActiveRecord::Migration
  def change
    add_column :bhas, :below_rotary, :decimal
    add_column :bhas, :above_rotary, :decimal
  end
end
