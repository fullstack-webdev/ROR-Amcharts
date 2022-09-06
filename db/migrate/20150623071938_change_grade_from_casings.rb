class ChangeGradeFromCasings < ActiveRecord::Migration
  def change
    remove_column :casings, :weight
    add_column :casings, :weight, :string

  end
end
