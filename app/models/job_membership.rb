class JobMembership < ActiveRecord::Base
    attr_accessible :job_role_id,
                    :user_name,
                    :phone_number,
                    :email,
                    :external_user,
                    :shift_type

    acts_as_tenant(:company)

    after_save :after_save
    after_destroy :after_destroy

    belongs_to :user
    belongs_to :job
    belongs_to :company

    validates :user, presence: true, :if => :not_external_user
    validates :job, presence: true

    #validates_uniqueness_of :user_id, scope: :job_id

    validates :job_role_id, presence: true

    before_save :default_values

    def default_values
        self.shift_type ||= SHIFT_NONE
    end


    OBSERVER = 1
    MANAGER = 2
    COORDINATOR = 3
    FIELD = 4
    SHOP = 5
    CREATOR = 6
    TOOL_COORDINATOR = 7

    COMPANY_MAN = 20
    GEOLOGIST = 21


    SHIFT_NONE = 0
    SHIFT_DAY = 1
    SHIFT_NIGHT = 2

    def not_external_user
        !self.external_user
    end


    def role_title
        case self.job_role_id
            when OBSERVER
                "Observer"
            when MANAGER
                "Manager"
            when COORDINATOR
                "Coordinator"
            when FIELD
                "Field"
            when SHOP
                "Shop"
            when CREATOR
                "Creator"
            when TOOL_COORDINATOR
                "Tool Coordinator"
            when COMPANY_MAN
                "Company Man"
            when GEOLOGIST
                "Geologist"
            else
                "-"
        end
    end

    def icon_css_style
        if self.shift_type > 0
            if self.shift_type == SHIFT_NIGHT
                return "member-icon-night"
            else
                return "member-icon-day"
            end
        end

        case self.job_role_id
            when OBSERVER
                ""
            when MANAGER
                "member-icon-manager"
            when COORDINATOR
                "member-icon-coordinator"
            when FIELD
                "member-icon-field"
            when SHOP
                "member-icon-shop"
            when TOOL_COORDINATOR
                "member-icon-tool-coordinator"
            when CREATOR
                ""
            when COMPANY_MAN
                "member-icon-tool-coordinator"
            when GEOLOGIST
                "member-icon-geologist"
            else
                ""
        end
    end

    def icon_image_css_style
        case self.job_role_id
            when OBSERVER
                ""
            when MANAGER
                "member-icon-image-manager"
            when COORDINATOR
                "member-icon-image-coordinator"
            when FIELD
                "member-icon-image-field"
            when SHOP
                "member-icon-image-shop"
            when TOOL_COORDINATOR
                "member-icon-image-coordinator"
            when CREATOR
                "member-icon-image-manager"
            when COMPANY_MAN
                "member-icon-tool-coordinator"
            when GEOLOGIST
                "member-icon-geologist"
            else
                ""
        end
    end

    def job_role_id_with_shift
        if self.shift_type > 0
            case self.job_role_id
                when JobMembership::FIELD
                    if self.shift_type == JobMembership::SHIFT_DAY
                        return 1000
                    else
                        return 1001
                    end
                when JobMembership::COMPANY_MAN
                    if self.shift_type == JobMembership::SHIFT_DAY
                        return 1005
                    else
                        return 1006
                    end
            end
        else
            self.job_role_id
        end
    end

    def duplicate
        job_membership = JobMembership.new
        job_membership.job = self.job
        job_membership.company = self.company
        job_membership.user = self.user
        job_membership.job_role_id = self.job_role_id
        job_membership.user_name = self.user_name
        job_membership.phone_number = self.phone_number
        job_membership.email = self.email
        job_membership.external_user = self.external_user
        job_membership.shift_type = self.shift_type
        job_membership
    end


    def color
        if self.user.present? && !self.user.name.blank?
            Digest::MD5.hexdigest(self.user.name)[0..5]
        elsif !self.user_name.blank?
            Digest::MD5.hexdigest(self.user_name)[0..5]
        else
            'd3d3d3'
        end
    end

    private
    def after_save
        update_counter_cache
    end

    def after_destroy
        update_counter_cache
    end

    def update_counter_cache
        if self.job.present?
            self.job.job_memberships_count = self.job.job_memberships.where("job_memberships.job_role_id != 6").count()
            self.job.save
        end
    end

end
