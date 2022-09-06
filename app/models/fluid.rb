class Fluid < ActiveRecord::Base
  attr_accessible :type,
                  :density,
                  :funnel_viscosity,
                  :filtrate,
                  :ph,
                  :pv,
                  :yp,
                  :mud_cake_thickness,
                  :high_gravity_densities,
                  :low_gravity_densities,
                  :high_gravity_volume,
                  :low_gravity_volume,
                  :drilled_solids_volume,
                  :rpm600,
                  :rpm300,
                  :rpm200,
                  :rpm100,
                  :rpm6,
                  :rpm3,
                  :seconds10,
                  :minutes10,
                  :water_volume,
                  :oil_volume,
                  :solid_volume,
                  :methylene_blue,
                  :drilling_fluid,
                  :bentonite,
                  :total_cl,
                  :k_acetate,
                  :potassium_bromide,
                  :sodium_bromide,
                  :calcium_bromide,
                  :potassium_formate,
                  :sodium_formate,
                  :cesium_formate,
                  :ammonium_chloride,
                  :kci,
                  :k2so4,
                  :cacl2,
                  :mgcl2,
                  :brine_density,
                  :entry_at,
                  :depth_from,
                  :depth_to,
                  :default

  acts_as_tenant(:company)

  validates_presence_of :company
  validates_presence_of :job
  validates :default, :inclusion => {:in => [true, false]}

  belongs_to :company
  belongs_to :job

  self.inheritance_column = :_type_disabled

  def self.attributes_to_ignore_when_comparing
      [:id, :company_id, :job_id, :created_at, :updated_at, :entry_at, :default]
  end

  def identical?(other)
      self.attributes.except(*self.class.attributes_to_ignore_when_comparing.map(&:to_s)) ==
              other.attributes.except(*self.class.attributes_to_ignore_when_comparing.map(&:to_s))
  end
end
