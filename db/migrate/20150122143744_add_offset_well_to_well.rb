class AddOffsetWellToWell < ActiveRecord::Migration
  def change
    add_column :wells, :offset_well_id, :integer
  end
end
