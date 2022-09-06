class ChangeWeightAndGradeFromCasings < ActiveRecord::Migration
  def change
    remove_column :casings, :weight
    add_column :casings, :weight, :float
    remove_column :casings, :grade
    add_column :casings, :grade, :string
  end
end
