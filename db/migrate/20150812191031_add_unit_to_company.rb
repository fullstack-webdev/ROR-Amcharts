class AddUnitToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :company_unit, :integer, :default => 0
  end
end
