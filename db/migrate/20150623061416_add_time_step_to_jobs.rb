class AddTimeStepToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :time_step, :integer, default: 1
  end
end
