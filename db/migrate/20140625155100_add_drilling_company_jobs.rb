class AddDrillingCompanyJobs < ActiveRecord::Migration
  def change
      add_column :jobs, :drilling_company_id, :integer
      add_column :jobs, :directional_drilling_company_id, :integer
      add_column :jobs, :fluids_company_id, :integer
  end
end
