class AddPositionToDrillingString < ActiveRecord::Migration
  def change
    add_column :drilling_strings, :position, :int
  end
end
