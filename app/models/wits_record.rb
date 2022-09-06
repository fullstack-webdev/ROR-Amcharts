class WitsRecord < ActiveRecord::Base
  establish_connection RealDBConfig

  attr_accessible :current_mse

  def self.set_table_name(id)
    self.table_name = "wits_records#{id}"
    self
  end

  def predicted_rop
    self.rop + Random.rand(30) + 10
  end
end