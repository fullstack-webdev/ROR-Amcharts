class RemoveCreateAccessFromUsers < ActiveRecord::Migration
  def up
      remove_column :users, :create_access
      remove_column :users, :write_access
  end

  def down
  end
end
