class Alert < ActiveRecord::Base
    attr_accessible :alert_type,
                    :target,
                    :expiration

    acts_as_tenant(:company)


    after_commit :flush_cache

    validates :company, presence: true
    validates :user, presence: true
    validates :created_by, presence: true
    validates :target, presence: true


    belongs_to :company
    belongs_to :user
    belongs_to :created_by, class_name: "User"
    belongs_to :job
    belongs_to :target, polymorphic: true


    ADDED_TO_JOB = 1
    TASK_ASSIGNED = 2
    NEW_MESSAGE = 3
    PRE_JOB_DATA_READY = 4
    POST_JOB_DATA_READY = 5
    JOB_SHIPPED = 6
    JOB_CLOSED = 7
    JOB_WARNING = 8
    ASSET_REQUEST = 10


    def self.add(user, alert_type, target, created_by, job = nil)
        return false if user.nil? or user.company.nil? or alert_type.blank? or target.blank?

        alert = Alert.new(alert_type: alert_type, target: target)
        alert.user = user
        alert.created_by = created_by
        alert.company = user.company
        alert.job = job

        alert.save!
        alert
    end

    def seen
        if self.expiration.nil?
            self.expiration = 7.days.from_now
            self.save
        elsif DateTime.now >= self.expiration
            self.destroy
        end
    end

    def self.cached_find_new_messages(user_id)
        Rails.cache.fetch([name, user_id.to_s + '-nm'], expires_in: 1.day) { User.find(user_id).alerts.where("alert_type = 3").count }
    end

    def self.cached_find_new_alerts(user_id)
        Rails.cache.fetch([name, user_id.to_s + '-na'], expires_in: 1.day) { User.find(user_id).new_alerts.count }
    end

    def flush_cache
        Rails.cache.delete([self.class.name, user_id.to_s + '-nm'])
        Rails.cache.delete([self.class.name, user_id.to_s + '-na'])
        #Rails.cache.delete([self.class.name, id])
    end

end
