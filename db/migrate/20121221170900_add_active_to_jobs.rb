class AddActiveToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :active, :boolean, :default => true
  end
end
