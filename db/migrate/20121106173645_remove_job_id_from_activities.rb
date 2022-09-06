class RemoveJobIdFromActivities < ActiveRecord::Migration
  def up
    remove_column :activities, :job_id
  end

  def down
    add_column :activities, :job_id, :integer
  end
end
