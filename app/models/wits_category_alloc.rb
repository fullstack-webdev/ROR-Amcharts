class WitsCategoryAlloc < ActiveRecord::Base
  attr_accessible :circulation_time,
                  :company_id,
                  :connection_time,
                  :drilling_time,
                  :entry_at,
                  :job_id,
                  :other_time,
                  :out_of_hole_time,
                  :reaming_in_time,
                  :reaming_out_time,
                  :reaming_time,
                  :total_well_time,
                  :tripping_in_time,
                  :tripping_out_time,
                  :wash_down_time,
                  :wash_up_time,
                  :washing_time


  belongs_to :company
  belongs_to :job

end
