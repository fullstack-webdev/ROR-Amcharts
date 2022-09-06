class LwdLog < ActiveRecord::Base
  attr_accessible :depth,
                  :GRAPI,
                  :RHOB,
                  :NPHI,
                  :DTCO,
                  :DTSM,
                  :HDMI,
                  :HDMX,
                  :pore_pressure,
                  :UCS,
                  :YM,
                  :LOT,
                  :Minifrac,
                  :emw_pore_pressure,
                  :emw_shear_failure,
                  :emw_min_stress,
                  :emw_fracture_pressure

  acts_as_tenant(:company)

  validates_presence_of :company
  validates_presence_of :job

  belongs_to :company
  belongs_to :job
end
