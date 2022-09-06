class AddWeightAndGradeToCasings < ActiveRecord::Migration
  def change
    add_column :casings, :weight, :float
    add_column :casings, :grade, :float
  end
end
