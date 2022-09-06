class ChangeCountStateFromWells < ActiveRecord::Migration
  def change
      remove_column :wells, :county
      remove_column :wells, :country_id
      remove_column :wells, :state_id

      add_column :fields, :county, :string
      add_column :fields, :country_id, :integer
      add_column :fields, :state_id, :integer
  end
end
