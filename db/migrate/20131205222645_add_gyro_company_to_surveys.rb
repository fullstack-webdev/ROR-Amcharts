class AddGyroCompanyToSurveys < ActiveRecord::Migration
  def change
    add_column :surveys, :gyro_company, :string
    add_column :surveys, :gyro_date, :datetime
  end
end
