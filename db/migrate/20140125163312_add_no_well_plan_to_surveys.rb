class AddNoWellPlanToSurveys < ActiveRecord::Migration
    def change
        add_column :surveys, :no_well_plan, :boolean, :default => false
    end
end
