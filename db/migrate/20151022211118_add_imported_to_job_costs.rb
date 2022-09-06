class AddImportedToJobCosts < ActiveRecord::Migration
  def change
    add_column :job_costs, :imported, :boolean
  end
end
