class AddCourseLengthToDrillingLogEntries < ActiveRecord::Migration
    def change
        add_column :drilling_log_entries, :course_length, :decimal, :default => 0.0
        add_column :drilling_log_entries, :hours, :decimal, :default => 0.0
    end
end
