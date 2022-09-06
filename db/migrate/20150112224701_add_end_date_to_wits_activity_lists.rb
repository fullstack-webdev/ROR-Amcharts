class AddEndDateToWitsActivityLists < ActiveRecord::Migration
  def change
    rename_column :wits_activity_lists, :time_stamp, :start_time
    add_column :wits_activity_lists, :end_time, :datetime
  end
end
