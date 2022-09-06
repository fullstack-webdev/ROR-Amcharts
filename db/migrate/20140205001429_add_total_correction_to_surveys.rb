class AddTotalCorrectionToSurveys < ActiveRecord::Migration
    def change
        add_column :surveys, :total_correction, :decimal
        add_column :surveys, :grid_type, :integer, :default => 1
    end
end
