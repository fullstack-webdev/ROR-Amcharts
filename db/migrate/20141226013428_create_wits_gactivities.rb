class CreateWitsGactivities < ActiveRecord::Migration
  def change
    create_table :wits_gactivities, {:id => false, :force => true} do |t|
      t.integer :company_id
      t.integer :job_id
      t.datetime :start_time
      t.datetime :end_time
      t.string :activity

      t.timestamps
    end
  end
end
