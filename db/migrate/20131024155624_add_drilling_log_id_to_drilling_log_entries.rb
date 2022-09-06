class AddDrillingLogIdToDrillingLogEntries < ActiveRecord::Migration
    def change
        add_column :drilling_log_entries, :drilling_log_id, :integer
        add_index :drilling_log_entries, :drilling_log_id
    end
end
