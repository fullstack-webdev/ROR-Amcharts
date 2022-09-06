class AddCreatePasswordToUsers < ActiveRecord::Migration
  def change
    add_column :users, :create_password, :boolean, default: false
  end
end
