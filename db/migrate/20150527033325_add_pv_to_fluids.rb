class AddPvToFluids < ActiveRecord::Migration
  def change
    add_column :fluids, :pv, :float
    add_column :fluids, :yp, :float
  end
end
