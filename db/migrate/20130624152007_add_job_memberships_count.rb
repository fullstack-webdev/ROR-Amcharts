class AddJobMembershipsCount < ActiveRecord::Migration
    def up
        add_column :jobs, :job_memberships_count, :integer, :default => 0

        Job.reset_column_information
        Job.find_each do |p|
            Job.update_counters p.id, :job_memberships_count => p.job_memberships.where("job_memberships.job_role_id != 6").count()
        end
    end

    def down
        remove_column :jobs, :job_memberships_count
    end
end
