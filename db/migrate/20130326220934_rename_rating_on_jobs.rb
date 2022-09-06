class RenameRatingOnJobs < ActiveRecord::Migration
  def change
      rename_column :jobs, :rating, :performance_rating
  end
end
