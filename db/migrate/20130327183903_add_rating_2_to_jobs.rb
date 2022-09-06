class AddRating2ToJobs < ActiveRecord::Migration
  def change
      add_column :jobs, :rating, :integer
  end
end
