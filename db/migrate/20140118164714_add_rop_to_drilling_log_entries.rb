class AddRopToDrillingLogEntries < ActiveRecord::Migration
    def change
        add_column :drilling_log_entries, :rop, :decimal
    end
end
