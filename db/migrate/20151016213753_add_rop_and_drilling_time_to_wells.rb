class AddRopAndDrillingTimeToWells < ActiveRecord::Migration
  def change
    add_column :wells, :rop, :float
    add_column :wells, :drilling_time, :float

    Well.all.each { |w| w.complete }
  end
end
