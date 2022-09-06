class AddJobNumberToJobs < ActiveRecord::Migration
    def change
        add_column :jobs, :job_number, :string
        remove_column :jobs, :client_contact_name
    end
end
