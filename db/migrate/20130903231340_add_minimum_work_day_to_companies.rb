class AddMinimumWorkDayToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :minimum_work_day, :integer, :default => 8
  end
end
