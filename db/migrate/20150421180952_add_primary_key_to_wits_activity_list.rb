class AddPrimaryKeyToWitsActivityList < ActiveRecord::Migration
  def change
    add_column :wits_activity_lists, :id, :primary_key
  end
end
