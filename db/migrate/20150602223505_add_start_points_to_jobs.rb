class AddStartPointsToJobs < ActiveRecord::Migration
    def change
        add_column :jobs, :section_last_entry_processed, :datetime
        add_column :jobs, :section_intermediate_start, :float
        add_column :jobs, :section_curve_start, :float
        add_column :jobs, :section_tangent_start, :float
        add_column :jobs, :section_drop_start, :float
    end
end
