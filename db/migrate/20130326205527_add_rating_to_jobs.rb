class AddRatingToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :rating, :integer
  end
end
