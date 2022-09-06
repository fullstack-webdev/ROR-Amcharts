class AddApiNumberToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :api_number, :string
  end
end
