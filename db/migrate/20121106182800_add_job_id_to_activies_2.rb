class AddJobIdToActivies2 < ActiveRecord::Migration
  def change
    add_column :activities, :job_id, :integer
    add_index :activities, :job_id

  end
end
