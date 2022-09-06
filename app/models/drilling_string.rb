class DrillingString < ActiveRecord::Base
  attr_accessible :type,
                  :outer_diameter,
                  :inner_diameter,
                  :weight,
                  :length,
                  :depth_from,
                  :depth_to,
                  :entry_at,
                  :position,
                  :default

  acts_as_tenant(:company)

  validates_presence_of :company
  validates_presence_of :job
  # validates :type, presence: true
  # validates :outer_diameter, presence: false, numericality: true
  # validates :inner_diameter, presence: false, numericality: true
  # validates :weight, presence: false, numericality: true
  # validates :length, presence: false, numericality: true
  validates :default, :inclusion => {:in => [true, false]}

  belongs_to :company
  belongs_to :job

  self.inheritance_column = :_type_disabled


  def self.attributes_to_ignore_when_comparing
      [:id, :company_id, :job_id, :created_at, :updated_at, :entry_at, :type, :default]
  end

  def identical?(other)
      self. attributes.except(*self.class.attributes_to_ignore_when_comparing.map(&:to_s)) ==
              other.attributes.except(*self.class.attributes_to_ignore_when_comparing.map(&:to_s))
  end

end
