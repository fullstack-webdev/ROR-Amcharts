class AddColumnToRigs < ActiveRecord::Migration
  def change
    add_column :rigs, :histogram, :text
  end
end
