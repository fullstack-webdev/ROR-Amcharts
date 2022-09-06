class CreateWitsHistogramData < ActiveRecord::Migration
  def change
    create_table :wits_histogram_data do |t|
      t.belongs_to :wits_histogram
      t.float :op_time
      t.integer :op_count

      t.timestamps
    end
    add_index :wits_histogram_data, :wits_histogram_id
  end
end
