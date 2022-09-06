class AddReferenceToWell < ActiveRecord::Migration
  def change
    add_index :wells, :offset_well_id
  end
end
