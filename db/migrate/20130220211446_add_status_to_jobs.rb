class AddStatusToJobs < ActiveRecord::Migration
    def change
        remove_column :jobs, :active
        add_column :jobs, :status, :integer
    end
end
