class AddDatumToWells < ActiveRecord::Migration
  def change
    add_column :wells, :datum, :integer, :default => 1
  end
end
