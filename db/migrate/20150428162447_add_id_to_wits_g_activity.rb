class AddIdToWitsGActivity < ActiveRecord::Migration
  def change
    add_column :wits_gactivities, :id, :primary_key
  end
end
