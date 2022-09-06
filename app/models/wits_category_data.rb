class WitsCategoryData < ActiveRecord::Base
  belongs_to :company
  belongs_to :job
  attr_accessible :average, :category, :duration, :entry_at, :op_count, :p10, :p50, :p90, :potential
end
