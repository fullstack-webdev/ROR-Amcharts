class RemovePerformanceRatingFromJobs < ActiveRecord::Migration
  def up
      remove_column :jobs, :performance_rating
  end

  def down
  end
end
