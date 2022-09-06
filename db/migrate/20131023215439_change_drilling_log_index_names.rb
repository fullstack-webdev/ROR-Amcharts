class ChangeDrillingLogIndexNames < ActiveRecord::Migration
  def change

      remove_index(:drilling_log_entries, :name => 'index_drilling_logs_on_bha_id')
      remove_index(:drilling_log_entries, :name => 'index_drilling_logs_on_company_id')
      remove_index(:drilling_log_entries, :name => 'index_drilling_logs_on_document_id')
      remove_index(:drilling_log_entries, :name => 'index_drilling_logs_on_job_id')
      remove_index(:drilling_log_entries, :name => 'index_drilling_logs_on_user_id')

      add_index :drilling_logs, :company_id
      add_index :drilling_logs, :document_id
      add_index :drilling_logs, :job_id

      add_index :drilling_log_entries, :company_id
      add_index :drilling_log_entries, :document_id
      add_index :drilling_log_entries, :job_id
      add_index :drilling_log_entries, :user_id
      add_index :drilling_log_entries, :bha_id
  end

end
