class ChangeAdminDefaultOnUsers < ActiveRecord::Migration
  def up
      change_column :users, :admin, :boolean, default: false
      change_column :users, :elephant_admin, :boolean, default: false
      change_column :users, :create_access, :boolean, default: false
      change_column :users, :write_access, :boolean, default: false
  end

  def down
  end
end
