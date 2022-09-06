class AddWorkDayTypeToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :work_day_type, :integer, :default => 1
  end
end
