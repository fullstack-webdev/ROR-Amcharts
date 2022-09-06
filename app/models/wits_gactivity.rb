class WitsGactivity < ActiveRecord::Base
  attr_accessible :activity,
                  :company_id,
                  :end_time,
                  :job_id,
                  :start_time


  belongs_to :company
  belongs_to :job

end
