class Activity < ActiveRecord::Base
    attr_accessible :activity_type,
                    :target,
                    :metadata,
                    :user_name

    acts_as_tenant(:company)

    belongs_to :company
    belongs_to :user
    belongs_to :job
    belongs_to :target, :polymorphic => true

    #default_scope :order => 'activities.created_at DESC', :limit => 10


    USER_CREATED = 1
    USER_UPDATED = 2
    USER_DESTROYED = 3
    CLIENT_CREATED = 4
    CLIENT_UPDATED = 5
    CLIENT_DESTROYED = 6
    PRODUCT_LINE_CREATED = 7
    PRODUCT_LINE_UPDATED = 8
    PRODUCT_LINE_DESTROYED = 9
    DOCUMENT_CREATED = 13
    DOCUMENT_DESTROYED = 14
    DYNAMIC_FIELD_CREATED = 15
    DYNAMIC_FIELD_DESTROYED = 16
    DISTRICT_CREATED = 17
    DISTRICT_UPDATED = 18
    DISTRICT_DESTROYED = 19


    JOB_CREATED = 100

    DOCUMENT_UPLOADED = 110
    DATA_EDITED = 111
    START_DATE = 112
    ASSET_ADDED = 113
    ASSET_REMOVED = 114

    JOB_MEMBER_ADDED = 120



    PRE_JOB_DATA_COMPLETE = 140
    JOB_APPROVED_TO_SHIP = 141
    POST_JOB_DATA_COMPLETE = 142
    JOB_APPROVED_TO_CLOSE = 143

    BEGIN_POST_JOB = 144
    BEGIN_ON_JOB = 145

    JOB_RATING = 160

    CREATE_BHA = 190
    UPDATE_BHA = 191
    DELETE_BHA = 192


    def message
        case self.activity_type
            when USER_CREATED
                "New User"
            when USER_UPDATED
                "User updated"
            when USER_DESTROYED
                "User deleted"
            when CLIENT_CREATED
                "New Customer"
            when CLIENT_UPDATED
                "Customer updated"
            when CLIENT_DESTROYED
                "Customer deleted"
            when PRODUCT_LINE_CREATED
                "New Product Line"
            when PRODUCT_LINE_UPDATED
                "Product Line updated"
            when PRODUCT_LINE_DESTROYED
                "Product Line deleted"
            when DOCUMENT_CREATED
                "New Document Template"
            when DOCUMENT_DESTROYED
                "Document Template updated"
            when DYNAMIC_FIELD_CREATED
                "New Custom Data Field"
            when DYNAMIC_FIELD_DESTROYED
                "Custom Data Field deleted"
            when DISTRICT_CREATED
                "New District"
            when DISTRICT_UPDATED
                "District updated"
            when DISTRICT_DESTROYED
                "District deleted"


            when JOB_CREATED
                "Job was created"
            when DATA_EDITED
                "Data edited"
            when START_DATE
                "Start date set"
            when DOCUMENT_UPLOADED
                "Document uploaded to job"
            when ASSET_ADDED
                "Asset added to job"
            when ASSET_REMOVED
                "Asset removed from job"
            when JOB_MEMBER_ADDED
                "Project member added to job"
            when PRE_JOB_DATA_COMPLETE
                "Pre-Job documents and info have been completed"
            when JOB_APPROVED_TO_SHIP
                "Job was approved to ship to location"
            when POST_JOB_DATA_COMPLETE
                "Post-Job documents and info have been completed"
            when JOB_APPROVED_TO_CLOSE
                "Job was completed"
            when BEGIN_POST_JOB
                "Started Post Job Phase"
            when BEGIN_ON_JOB
                "Started Job Phase"
        end
    end

    def self.add(user, activity_type, target, metadata = "", job = nil)
        return false if user.nil? or user.company.nil? or activity_type.blank? or target.blank?

        activity = Activity.new(activity_type: activity_type, target: target, metadata: metadata)
        activity.user = user
        if user
            activity.user_name = user.name
        end
        activity.company = user.company
        activity.job = job

        activity.save!
    end

    def self.admin_activities_for_company(company)
        where("company_id = :company_id", company_id: company.id).where("activity_type >= :start_range AND activity_type <= :end_range", start_range: 1, end_range: 100).order("created_at DESC")
    end

    def self.activities_for_job(job)
        where("job_id = :job_id", job_id: job.id).where("activity_type >= :start_range AND activity_type <= :end_range", start_range: 100, end_range: 200).order("created_at DESC")
    end

    def self.activities_for_jobs(jobs)

        #if Rails.env == "development"
        #    where("activities.job_id IN (?)", jobs.map { |j| j.id }).where("activity_type >= :start_range AND activity_type <= :end_range", start_range: 100, end_range: 200).order("activities.created_at DESC").group("activities.job_id")
        #else
            where("activities.job_id IN (?)", jobs.map { |j| j.id }).where("activity_type >= :start_range AND activity_type <= :end_range", start_range: 100, end_range: 200).order("activities.created_at DESC")
        #end
    end

    #Activity.select("DISTINCT ON (job_id) *").where("activities.job_id IN (?)", jobs.map { |j| j.id }).where("activity_type >= :start_range AND activity_type <= :end_range", start_range: 100, end_range: 200).order("job_id, created_at DESC")

    def self.activities_for_user(user)
        where("user_id = :user_id", user_id: user.id).where("activity_type >= :start_range AND activity_type <= :end_range", start_range: 100, end_range: 200).order("created_at DESC")
    end

    def self.activities_for_user_today(user)

        #if Rails.env == "development"
        #    where("activities.job_id IN (?)", user.jobs.map { |j| j.id }).where("created_at > ?", (Time.now - 1.day)).where("activity_type >= :start_range AND activity_type <= :end_range", start_range: 100, end_range: 200).order("activities.created_at DESC").group("activities.job_id")
        #else
            where("activities.job_id IN (?)", user.jobs.map { |j| j.id }).where("created_at > ?", (Time.now - 1.day)).where("activity_type >= :start_range AND activity_type <= :end_range", start_range: 100, end_range: 200).order("activities.created_at DESC")
        #end


        #where("job_id IN (?)", user.jobs.map { |j| j.id }).where("created_at > ?", (Time.now - 1.day)).where("activity_type >= :start_range AND activity_type <= :end_range", start_range: 100, end_range: 200).order("created_at DESC")
    end

end
