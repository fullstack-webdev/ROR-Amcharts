class AddHorizontalDeviationToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :horizontal_deviation, :float, default: 0.0
  end
end
