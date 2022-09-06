class AddFinishedAtToWells < ActiveRecord::Migration
  def change
    add_column :wells, :finished_at, :datetime
  end
end
