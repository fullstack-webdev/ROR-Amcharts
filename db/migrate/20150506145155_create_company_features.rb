class CreateCompanyFeatures < ActiveRecord::Migration
  def change
    create_table :company_features do |t|
      t.integer :company_id
      t.integer :feature
      t.boolean :enabled

      t.timestamps
    end
  end
end
