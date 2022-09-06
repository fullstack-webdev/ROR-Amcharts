class Company < ActiveRecord::Base
    attr_accessible :name,
                    :address_line_1,
                    :address_line_2,
                    :postal_code,
                    :city,
                    :state,
                    :country,
                    :logo,
                    :logo_large,
                    :phone_number,
                    :support_email,
                    :website,
                    :vpn_range,
                    :test_company,
                    :inventory_active,
                    :minimum_work_day,
                    :work_day_type,
                    :payroll_schedule,
                    :operator_number,
                    :railroad_signer,
                    :railroad_signer_title,
                    :company_unit

    after_commit :flush_cache

    validates :name, presence: true, uniqueness: true, length: {maximum: 50}

    has_many :users, dependent: :destroy, order: "name ASC"
    has_many :roles, dependent: :destroy, class_name: "UserRole"
    has_many :districts, dependent: :destroy, order: "name ASC"
    has_many :rigs, dependent: :destroy
    has_many :fields, dependent: :destroy, order: "name ASC"
    has_many :wells, dependent: :destroy, order: "name ASC"
    has_many :jobs, dependent: :destroy, order: "jobs.created_at ASC"
    has_many :dynamic_fields, dependent: :destroy
    has_many :documents, dependent: :destroy
    has_many :alerts, dependent: :destroy
    has_many :activities, dependent: :destroy
    has_many :drilling_logs, dependent: :destroy
    has_many :surveys, dependent: :destroy
    has_many :bhas, dependent: :destroy
    has_many :drilling_strings, dependent: :destroy
    has_many :casings, dependent: :destroy
    has_many :bits, dependent: :destroy
    has_many :fluids, dependent: :destroy
    has_many :lwd_logs, dependent: :destroy
    has_many :job_costs, dependent: :destroy
    has_many :event_warnings, dependent: :destroy
    has_many :company_features, dependent: :destroy
    has_many :torque_drag_datas, dependent: :destroy

    has_many :wits_category_allocs, dependent: :destroy, order: "entry_at DESC"
    has_many :wits_category_lists, dependent: :destroy, order: "time_stamp ASC"
    has_many :wits_activity_lists, dependent: :destroy, order: "start_time ASC"
    # has_many :wits_category_datas, order: "time_stamp ASC"
    has_many :wits_gactivities, dependent: :destroy
    has_many :wits_histograms, dependent: :destroy
    has_many :wits_datas, order: "entry_at ASC"
    belongs_to :admin
    has_many :programs, dependent: :destroy, order: "name ASC"


    HOURLY_WORK_DAY = 1
    DAILY_WORK_DAY = 2

    PAYROLL_NONE = 0
    PAYROLL_BIMONTHLY_EVEN = 1

    UNIT_IMPERIAL = 0
    UNIT_METRIC = 1

    def self.possible_units
      [['Imperial', UNIT_IMPERIAL], ['Metric', UNIT_METRIC]]
    end

    def company_unit_str
      case company_unit
        when UNIT_METRIC
          'Metric'
        when UNIT_IMPERIAL
          'Imperial'
      end
    end

    def active_jobs
        self.jobs.where("jobs.status >= 1 AND jobs.status < 50")
    end

    def warnings_list
      jobs = self.jobs.reorder('opened_at desc')
      EventWarning.where(:job_id => jobs).order('opened_at DESC')
    end

    def self.cached_find(id)
        Rails.cache.fetch([name, id], expires_in: 30.days) { find(id) }
    end

    def flush_cache
        Rails.cache.delete([self.class.name, id])
    end

    def current_warnings_list
      active_jobs = self.active_jobs.collect { |job| job.id }
      EventWarning.includes(job: :well).where(:job_id => active_jobs).where(:closed_at => nil).order('opened_at DESC')
    end

end
