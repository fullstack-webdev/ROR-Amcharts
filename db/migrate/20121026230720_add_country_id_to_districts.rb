class AddCountryIdToDistricts < ActiveRecord::Migration
  def change
    add_column :districts, :country_id, :integer
    add_column :districts, :state_id, :integer

    add_index :districts, :country_id
    add_index :districts, :state_id
  end
end
