class AddUserNameToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :user_name, :string
  end
end
