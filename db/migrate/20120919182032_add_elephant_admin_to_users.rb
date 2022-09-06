class AddElephantAdminToUsers < ActiveRecord::Migration
  def change
    add_column :users, :elephant_admin, :boolean
  end
end
