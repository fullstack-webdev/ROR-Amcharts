class AddTotalCirculationToBhas < ActiveRecord::Migration
    def change
        add_column :bhas, :total_circulation, :decimal, :default => 0.0
    end
end
