class RemoveCasingSizeFromDrillingLogEntries < ActiveRecord::Migration
  def change
      remove_column :drilling_log_entries, :casing_size
  end
end
