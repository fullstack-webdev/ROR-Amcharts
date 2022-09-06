class WitsActivityList < ActiveRecord::Base
  attr_accessible :category_name,
                  :company_id,
                  :job_id,
                  :operation_time,
                  :start_time
                  :end_time
                  :hole_depth
                  :bit_depth

  belongs_to :company
  belongs_to :job
end
