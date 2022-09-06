class AddTimeZoneToDistricts < ActiveRecord::Migration
  def change
    add_column :districts, :time_zone, :string
  end
end
