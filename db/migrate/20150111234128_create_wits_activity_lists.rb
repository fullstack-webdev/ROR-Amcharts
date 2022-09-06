class CreateWitsActivityLists < ActiveRecord::Migration
  def change
    create_table :wits_activity_lists, {:id => false, :force => true} do |t|

      t.integer :company_id
      t.integer :job_id
      t.datetime :time_stamp
      t.integer :operation_time
      t.string :activity_name
      t.timestamps
    end
  end
end
