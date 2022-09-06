class AddTotalCostToJobs < ActiveRecord::Migration
    def change
        add_column :jobs, :total_cost, :decimal, :default => 0.0
        add_column :jobs, :proposed_cost, :decimal, :default => 0.0
    end
end
