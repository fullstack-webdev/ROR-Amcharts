class AddPerfectWellRatioToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :perfect_well_ratio, :float
  end
end
