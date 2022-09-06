class AddDepthToFluids < ActiveRecord::Migration
  def change
    add_column :fluids, :in_depth, :float
  end
end
