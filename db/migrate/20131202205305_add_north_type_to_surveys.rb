class AddNorthTypeToSurveys < ActiveRecord::Migration
  def change
    add_column :surveys, :north_type, :integer, :default => 1
  end
end
