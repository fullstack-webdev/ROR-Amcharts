class AddOperatorNumberToCompanies < ActiveRecord::Migration
    def change
        add_column :companies, :operator_number, :string
        add_column :companies, :railroad_signer, :string
        add_column :companies, :railroad_signer_title, :string

    end
end
