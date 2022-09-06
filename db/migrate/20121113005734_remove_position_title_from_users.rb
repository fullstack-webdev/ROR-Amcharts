class RemovePositionTitleFromUsers < ActiveRecord::Migration
  def up
      remove_column :users, :position_title
  end

  def down
  end
end
