class AddTestCompanyToCompanies < ActiveRecord::Migration
    def change
        add_column :companies, :test_company, :boolean, :default => false
    end
end
