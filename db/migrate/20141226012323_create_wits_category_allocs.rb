class CreateWitsCategoryAllocs < ActiveRecord::Migration
  def change
    create_table :wits_category_allocs, {:id => false, :force => true} do |t|
      t.integer :company_id
      t.integer :job_id
      t.float :total_well_time
      t.datetime :entry_at
      t.float :reaming_in_time
      t.float :reaming_in_per
      t.float :reaming_out_time
      t.float :reaming_out_per
      t.float :reaming_time
      t.float :reaming_per
      t.float :wash_up_time
      t.float :wash_up_per
      t.float :wash_down_time
      t.float :wash_down_per
      t.float :washing_time
      t.float :washing_per
      t.float :circulation_time
      t.float :circulation_per
      t.float :drilling_time
      t.float :drilling_per
      t.float :connection_time
      t.float :connection_per
      t.float :tripping_out_time
      t.float :tripping_out_per
      t.float :tripping_in_time
      t.float :tripping_in_per
      t.float :out_of_hole_time
      t.float :out_of_hole_per
      t.float :other_time
      t.float :other_per

      t.timestamps
    end
  end
end
