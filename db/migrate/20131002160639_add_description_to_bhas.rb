class AddDescriptionToBhas < ActiveRecord::Migration
  def change
    add_column :bhas, :description, :string
  end
end
