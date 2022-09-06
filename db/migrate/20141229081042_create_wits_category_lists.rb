class CreateWitsCategoryLists < ActiveRecord::Migration
  def change
    create_table :wits_category_lists, {:id => false, :force => true} do |t|
      t.string :time_index
      t.integer :company_id
      t.integer :job_id
      t.datetime :time_stamp
      t.integer :operation_time
      t.string :category_name

      t.timestamps
    end
  end
end
