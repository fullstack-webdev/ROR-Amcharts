class CreatePostJobReportDocuments < ActiveRecord::Migration
    def change
        create_table :post_job_report_documents do |t|
            t.integer :document_id
            t.integer :job_template_id
            t.integer :ordering

            t.timestamps
        end

        add_index :post_job_report_documents, :document_id
        add_index :post_job_report_documents, :job_template_id
    end
end
