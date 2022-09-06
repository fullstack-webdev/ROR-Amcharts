class AddPostJobReportOrderToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :post_job_report_order, :integer
  end
end
