class WitsCategoryList < ActiveRecord::Base
  attr_accessible :category_name,
                  :company_id,
                  :job_id,
                  :operation_time,
                  :time_index,
                  :time_stamp


  belongs_to :company
  belongs_to :job

end
