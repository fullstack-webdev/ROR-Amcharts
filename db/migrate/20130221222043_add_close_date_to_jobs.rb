class AddCloseDateToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :close_date, :datetime
  end
end
