class RenameDrillingLogToDrillingLogEntry < ActiveRecord::Migration
    def change
        rename_table :drilling_logs, :drilling_log_entries
    end
end
