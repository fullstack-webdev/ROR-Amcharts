class AddAcceptedTouToUsers < ActiveRecord::Migration
  def change
    add_column :users, :accepted_tou, :boolean, :default => false
  end
end
