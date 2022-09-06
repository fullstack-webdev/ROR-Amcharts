class DrillingLogEntry < ActiveRecord::Base
    attr_accessible :comment,
                    :entry_at,
                    :end_time,
                    :hours,
                    :activity_code,
                    :depth,
                    :user_name,
                    :additional

    acts_as_tenant(:company)

    validates :comment, length: {minimum: 0, maximum: 2500}
    validates :entry_at, presence: true
    validates_presence_of :company_id
    validates_presence_of :job_id

    validates_uniqueness_of :comment, :scope => [:job_id, :entry_at, :additional, :end_time]

    belongs_to :company
    belongs_to :job



end
