class AddOffsetWellIdToRigs < ActiveRecord::Migration
  def change
    add_column :rigs, :program, :integer
    add_column :rigs, :offset_well_id, :integer
  end
end
