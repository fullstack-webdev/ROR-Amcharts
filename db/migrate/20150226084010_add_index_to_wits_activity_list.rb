class AddIndexToWitsActivityList < ActiveRecord::Migration
  def change
    add_index :wits_activity_lists, :company_id
    add_index :wits_activity_lists, :job_id
    add_index :wits_activity_lists, :start_time
    add_index :wits_activity_lists, :end_time
  end
end
