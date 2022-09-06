class AddCompanyToPrograms < ActiveRecord::Migration
  def change
    add_column :programs, :company_id, :integer
  end
end
