class AddInvalidLoginAttemptsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :invalid_login_attempts, :integer, :default => 0
  end
end
