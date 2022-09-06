class WitsHistogram < ActiveRecord::Base
  belongs_to :job
  belongs_to :company
  has_many :wits_histogram_datas
  attr_accessible :avg_time, :category, :fifty_per, :max_op_time, :ninety_per, :op_count, :ten_per, :total_category_time, :total_time
end
