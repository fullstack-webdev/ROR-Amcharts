class HoleSize < ActiveRecord::Base
  attr_accessible :diameter,
                  :depth,
                  :entry_at,
                  :default

  acts_as_tenant(:company)

  validates_presence_of :company
  validates_presence_of :job
  validates :diameter, presence: true, numericality: true
  validates :depth, presence: true, numericality: true
  validates :default, :inclusion => {:in => [true, false]}

  belongs_to :company
  belongs_to :job


  def self.attributes_to_ignore_when_comparing
      [:id, :company_id, :job_id, :created_at, :updated_at, :entry_at, :default]
  end

  def identical?(other)
      self. attributes.except(*self.class.attributes_to_ignore_when_comparing.map(&:to_s)) ==
              other.attributes.except(*self.class.attributes_to_ignore_when_comparing.map(&:to_s))
  end

end
