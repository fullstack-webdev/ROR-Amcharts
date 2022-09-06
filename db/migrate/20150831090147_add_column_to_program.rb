class AddColumnToProgram < ActiveRecord::Migration
  def change
    add_column :programs, :histogram, :text
  end
end
