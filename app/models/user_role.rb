class UserRole < ActiveRecord::Base
    attr_accessible :role_id

    after_commit :flush_cache

    acts_as_tenant(:company)

    validates :title, presence: true, length: {maximum: 50}, uniqueness: {case_sensitive: false, scope: :company_id}
    validates_presence_of :company

    belongs_to :company

    ROLE_CORVA_ADMIN = 1

    ROLE_FIELD_ENGINEER = 30
    ROLE_FULL_ACCESS = 57
    ROLE_ADMIN = 10


    def self.from_company(company)
        where("company_id = :company_id", company_id: company.id).order("title ASC")
    end

    def self.from_user(user)
        UserRole.from_role user.role_id, user.company
    end

    def admin?
        self.role_id == ROLE_ADMIN
    end

    def self.from_role(role_id, company)
        user_role = UserRole.new(role_id: role_id.to_i)
        user_role.company = company
        user_role
    end

    def limit_to_assigned_jobs?
        self.role_id >= 30 && self.role_id <= 39
    end

    def self.cached_find(company_id, role_id)
        Rails.cache.fetch([name, company_id.to_s + '-' +  role_id.to_s], expires_in: 30.days) { where("company_id = :company_id AND role_id = :role_id", company_id: company_id, role_id: role_id).limit(1).first || '' }
    end

    def flush_cache
        Rails.cache.delete([self.class.name, company_id.to_s + '-' +  role_id.to_s])
    end

end
