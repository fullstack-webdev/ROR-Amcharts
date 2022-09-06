class District < ActiveRecord::Base
    attr_accessible :name,
                    :time_zone,
                    :location,
                    :region,
                    :address_line_1,
                    :address_line_2,
                    :city,
                    :postal_code,
                    :phone_number,
                    :support_email,
                    :master

    acts_as_tenant(:company)


    validates :name, presence: true, length: {maximum: 50}
    validates :company, presence: true

    belongs_to :company
    belongs_to :country
    belongs_to :state

    belongs_to :master_district, class_name: "District"

    has_many :districts, foreign_key: "master_district_id", dependent: :destroy
    has_many :fields, order: "name ASC"
    has_many :jobs, order: "jobs.close_date DESC, jobs.created_at DESC"

    def self.from_company(company)
        where("company_id = :company_id", company_id: company.id).order("name ASC")
    end

    def personnel
        User.where("district_id = ?", self.id)
    end

end
