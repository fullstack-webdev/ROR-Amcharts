class Document < ActiveRecord::Base
    attr_accessible :category,
                    :name,
                    :status,
                    :document_type,
                    :template,
                    :url,
                    :read_only,
                    :ordering,
                    :user_name,
                    :access_level

    acts_as_tenant(:company)

    after_commit :flush_cache

    validates :name, presence: true, length: {maximum: 150}
    validates :category, length: {maximum: 50}
    validates :company, presence: true

    belongs_to :document_template, class_name: "Document"
    belongs_to :job
    belongs_to :company

    belongs_to :user, class_name: "User"
    belongs_to :owner, :polymorphic => true

    before_create :default_name

    has_one :post_job_report_document, :dependent => :destroy

    DOCUMENT = 0
    PROTECTED_DOCUMENT = 50
    CHECKLIST = 1
    JOB_LOG = 2
    DRILLING_LOG = 3
    CUSTOM_DATA = 4
    BOTTOM_HOLE_ASSEMBLY = 5
    SURVEY = 6
    WELL_PLAN = 7
    ASSET_LIST = 8

    NOTICES = "Notices"
    PRE_JOB = "Pre-Job"
    POST_JOB = "Post-Job"
    ON_JOB = "On-Job"
    POST_JOB_REPORT_PART = "Post Job Report Part"
    POST_JOB_REPORT = "Post Job Report"
    PART_REDRESS = "Part Redress"

    DOCUMENT_RESTRICTED = 3

    def default_name
        self.name ||= File.basename(url, '.*').titleize if url
    end

    def file_name
        File.basename(url).titleize if url
    end

    def document_type_string
        case self.document_type
            when Document::DOCUMENT
                "Document"
            when Document::CHECKLIST
                "Checklist"
            when Document::JOB_LOG
                "Job Log"
            when Document::DRILLING_LOG
                "Drilling Log"
            when Document::BOTTOM_HOLE_ASSEMBLY
                "Bottom Hole Assembly"
            when Document::WELL_PLAN
                "Well Plan"
            when Document::SURVEY
                "Survey"
            when Document::ASSET_LIST
                "Asset List"
        end
    end

    def full_url
        if !self.url.blank?
            s3 = AWS::S3.new
            obj = s3.buckets['elephant-docs'].objects[self.url].url_for(:read)
            obj.to_s
        else
            ""
        end
    end

    def self.from_job(job)
        where("job_id = :job_id", job_id: job.id)
    end

    def document_collection
        collection = []
        if !self.job.nil?
            case self.category
                when Document::NOTICES
                    collection = self.job.notices_documents
                when Document::PRE_JOB
                    collection = self.job.pre_job_documents
                when Document::POST_JOB
                    collection = self.job.post_job_documents
                when Document::ON_JOB
                    collection = self.job.on_job_documents
            end
        end

        if collection.nil?
            collection = []
        end

        collection
    end

    def delete_document
        if !self.url.blank?
            s3 = AWS::S3.new
            obj = s3.buckets['elephant-docs'].objects[self.url].delete
            obj.to_s
        end
    end

    def upload_info
        sts = AWS::STS.new()
        policy = AWS::STS::Policy.new
        policy.allow(
                :actions => ["s3:PutObject"],
                :resources => "arn:aws:s3:::elephant-docs/*")

        session = sts.new_federated_session(
                'User_' + UserObserver.current_user.id.to_s,
                :policy => policy,
                :duration => 2*60*60)

        record = Struct.new(:uploadKey, :accessKeyId, :secretAccessKey, :sessionToken) do
            def to_xml(options = {})
                "<uploadKey>docs/#{uploadKey}</uploadKey><accessKeyId>#{accessKeyId}</accessKeyId><secretAccessKey>#{secretAccessKey}</secretAccessKey><sessionToken>#{sessionToken}</sessionToken>"
            end
        end

        record.new(SecureRandom.hex,
                   session.credentials[:access_key_id],
                   session.credentials[:secret_access_key],
                   session.credentials[:session_token]).to_xml
    end


    def add_notices_on_active_jobs
        self.company.jobs.where("jobs.status >= 1 AND jobs.status < 50").each do |job|
            job_document = Document.new
            job_document.category = self.category
            job_document.name = self.name
            job_document.status = self.status
            job_document.document_type = self.document_type
            job_document.read_only = self.read_only
            job_document.ordering = self.ordering
            job_document.template = false
            job_document.url = nil
            job_document.document_template = self
            job_document.job = job
            job_document.company = self.company
            job_document.save

            job.unique_participants.each do |participant|
                UserMailer.new_notice_on_job(participant, job, self).deliver
            end
        end
    end

    def delete_notice_on_jobs document_id
        Document.where("documents.document_template_id = ?", document_id).each do |document|
            document.destroy
        end
    end

    def empty?
        if self.document_type == DOCUMENT
            return self.url.blank?
        elsif self.document_type == JOB_LOG
            return JobLog.where(:document_id => self.id).count == 0
        elsif self.document_type == DRILLING_LOG
            drilling_log_sql = DrillingLog.where(:document_id => self.id).select(:id).to_sql
            return DrillingLogEntry.where("drilling_log_entries.drilling_log_id IN (#{drilling_log_sql})").count == 0
        elsif self.document_type == BOTTOM_HOLE_ASSEMBLY
            return true if self.job.nil?
            bha = Bha.joins(document: {job: :well}).where("wells.id = ?", self.job.well_id).order("bhas.updated_at DESC").limit(1).first
            return bha.nil?
        elsif self.document_type == WELL_PLAN
            return true if self.job.nil?
            survey = Survey.joins(document: {job: :well }).where(:plan => true).where("wells.id = ?", self.job.well_id).limit(1).first
            return survey.nil? || survey.survey_points.count == 0
        elsif self.document_type == SURVEY
            return true if self.job.nil?
            survey = Survey.joins(document: {job: :well }).where(:plan => false).where("wells.id = ?", self.job.well_id).limit(1).first
            return survey.nil? || survey.survey_points.count == 0
        elsif self.document_type == ASSET_LIST
            return true if self.job.nil?
            asset_list = AssetList.where("asset_lists.job_id = ?", self.job_id).first
            return asset_list.nil? || asset_list.asset_list_entries.count == 0
        end

        return true
    end

    def shareable?
        if self.document_type == DOCUMENT
            return true
        else
            return false
        end
    end


    def duplicate
        document = Document.new
        document.category = self.category
        document.access_level = self.access_level
        document.name = self.name
        document.status = self.status
        document.document_type = self.document_type
        document.read_only = self.read_only
        document.ordering = self.ordering
        document.template = self.template
        document.url = self.url
        document.document_template = self.document_template
        document.job = self.job
        document.company = document.company
        document
    end

    def flush_cache
        if self.job.present?
            self.job.flush_cache_status_percentage
        end
    end

end
