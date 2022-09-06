class AddExpirationToAlerts < ActiveRecord::Migration
  def change
    add_column :alerts, :expiration, :datetime
  end
end
