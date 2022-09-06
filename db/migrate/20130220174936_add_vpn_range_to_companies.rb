class AddVpnRangeToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :vpn_range, :string
  end
end
