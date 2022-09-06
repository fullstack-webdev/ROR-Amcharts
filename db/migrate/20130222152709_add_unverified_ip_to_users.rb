class AddUnverifiedIpToUsers < ActiveRecord::Migration
  def change
    add_column :users, :unverified_network, :string
    add_column :users, :network_access_code, :string
    add_column :users, :verified_networks, :string, :limit => 2000
  end
end
