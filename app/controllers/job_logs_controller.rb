class JobLogsController < ApplicationController
    before_filter :signed_in_user, only: [:index, :create, :update]

    def index
        @document = Document.find(params[:document])
        not_found unless !@document.nil?
        not_found unless @document.company == current_user.company && @document.document_type == Document::JOB_LOG

        @job_logs = JobLog.where(:company_id => current_user.company_id).where(:document_id => @document.id).order("entry_at ASC")
    end

    def create
        document_id = params[:job_log][:document_id]
        params[:job_log].delete(:document_id)

        @document = Document.find(document_id)
        not_found unless @document.company == current_user.company && @document.document_type == Document::JOB_LOG

        override_date = nil
        if params[:job_log][:override_date] == "1"
            override_date = Time.strptime("#{params[:date]} #{params[:hour]}:#{params[:minute]}:00 #{params[:meridian]}", '%m/%d/%Y %I:%M:%S %p').in_time_zone(Time.zone)
        end

        params[:job_log].delete(:override_date)

        @job_log = JobLog.new(params[:job_log])
        @job_log.document = @document
        not_found unless @job_log.document.company == current_user.company
        @job_log.company = current_user.company
        @job_log.job = @job_log.document.job
        @job_log.user = current_user
        @job_log.user_name = current_user.name

        if override_date.nil?
            @job_log.entry_at = Time.zone.now
        else
            @job_log.entry_at = override_date
        end

        @job_log.save
    end

    def update

    end

end
