class AddSharedJobToJobs < ActiveRecord::Migration
    def change
        add_column :jobs, :shared, :boolean, :default => true
    end
end
