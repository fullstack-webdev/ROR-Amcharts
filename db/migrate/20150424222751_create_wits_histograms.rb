class CreateWitsHistograms < ActiveRecord::Migration
  def change
    create_table :wits_histograms do |t|
      t.belongs_to :job
      t.belongs_to :company
      t.integer :category
      t.float :ten_per
      t.float :fifty_per
      t.float :ninety_per
      t.integer :op_count
      t.float :total_time
      t.float :total_category_time
      t.float :avg_time
      t.float :max_op_time

      t.timestamps
    end
    add_index :wits_histograms, :job_id
    add_index :wits_histograms, :company_id
  end
end
