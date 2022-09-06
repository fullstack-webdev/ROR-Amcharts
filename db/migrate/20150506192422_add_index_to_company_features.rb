class AddIndexToCompanyFeatures < ActiveRecord::Migration
    def change
        add_index :company_features, :company_id
    end
end
