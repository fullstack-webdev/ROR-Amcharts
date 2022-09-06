class AddRemainingCompanyIds < ActiveRecord::Migration
    def up
        add_column :job_memberships, :company_id, :integer
        add_column :messages, :company_id, :integer
        add_column :post_job_report_documents, :company_id, :integer
    end

    def down
    end
end
