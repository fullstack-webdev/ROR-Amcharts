class Field < ActiveRecord::Base
    attr_accessible :name,
                    :county

    acts_as_tenant(:company)

    validates :name, presence: true, length: {maximum: 50}
    validates_uniqueness_of :name, :case_sensitive => false, scope: :district_id
    validates :company, presence: true
    validates :district, presence: true

    belongs_to :company
    belongs_to :district
    belongs_to :country
    belongs_to :state

    has_many :wells, order: "name ASC"

    def self.from_company(company)
        where("company_id = :company_id", company_id: company.id).order("name ASC")
    end

    def jobs(company)
        Job.from_company(company).where(:field_id => self.id)
    end

end
