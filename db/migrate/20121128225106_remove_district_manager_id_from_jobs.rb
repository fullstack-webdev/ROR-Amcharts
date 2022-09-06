class RemoveDistrictManagerIdFromJobs < ActiveRecord::Migration
  def up
      remove_column :jobs, :district_manager_id
      remove_column :jobs, :sales_engineer_id
  end

  def down
  end
end
