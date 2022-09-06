class RemoveTimestampsFromWitsActivityList < ActiveRecord::Migration
  def up
    remove_column :wits_activity_lists, :created_at
    remove_column :wits_activity_lists, :updated_at
  end

  def down
    add_column :wits_activity_lists, :updated_at, :string
    add_column :wits_activity_lists, :created_at, :string
  end
end
