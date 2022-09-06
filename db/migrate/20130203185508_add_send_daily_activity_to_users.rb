class AddSendDailyActivityToUsers < ActiveRecord::Migration
  def change
    add_column :users, :send_daily_activity, :boolean, :default => true
  end
end
