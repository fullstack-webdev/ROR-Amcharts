class CreateWitsCategoryData < ActiveRecord::Migration
  def change
    create_table :wits_category_data, {:id => false, :force => true} do |t|
      t.belongs_to :company
      t.belongs_to :job
      t.datetime :entry_at
      t.string :category
      t.integer :op_count
      t.float :average
      t.float :duration
      t.float :potential
      t.float :p10
      t.float :p50
      t.float :p90

    end
    add_index :wits_category_data, :company_id
    add_index :wits_category_data, :job_id
  end
end
