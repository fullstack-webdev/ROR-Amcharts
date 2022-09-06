class WitsHistogramData < ActiveRecord::Base
  belongs_to :wits_histogram
  attr_accessible :op_count, :op_time
end
