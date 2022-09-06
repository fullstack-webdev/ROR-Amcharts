class AddIndexToWitsGactivity < ActiveRecord::Migration
  def change
    add_index :wits_gactivities, :job_id
    add_index :wits_gactivities, :company_id
    add_index :wits_gactivities, :start_time
    add_index :wits_gactivities, :end_time
  end
end
