class DrillingLogsController < ApplicationController
    before_filter :signed_in_user, only: [:index]

    skip_before_filter :verify_traffic, only: [:show]
    skip_before_filter :session_expiry, only: [:show]
    skip_before_filter :update_session_expiration, only: [:show]

    before_filter :check_user_or_access_code, only: [:show]

    def check_user_or_access_code
        if !signed_in?
            share = cookies[:share]
            access_code = cookies[:access_code]
            email = cookies[:email]

            if !share.blank? && !access_code.blank? && !email.blank?

                @drilling_log = DrillingLog.find_by_id(params[:id])
            else
                signed_in_user
            end
        else
            verify_traffic
            session_expiry unless !signed_in?
            update_session_expiration unless !signed_in?
            signed_in_user unless !signed_in?
        end
    end
    include DrillingLogsHelper

    def index
        if params[:job].present?
            @job = Job.find_by_id(params[:job])
            not_found unless !@document.nil?
            @drilling_log = DrillingLog.includes(:job).where("jobs.well_id = ?", @job.well_id).last

            cookies[:return_job] = params[:return_job]

            if @drilling_log.nil?
                if @document.document_type == Document::DRILLING_LOG
                    @drilling_log = DrillingLog.new
                    @drilling_log.company = current_user.company
                    @drilling_log.job = @job
                    @drilling_log.well = @job.well
                    @drilling_log.save
                    redirect_to @drilling_log
                end
            else
                redirect_to @drilling_log
            end
        end
    end

    def show
        @drilling_log = DrillingLog.find(params[:id])
        not_found unless @drilling_log.present?
        @bhas = Bha.joins(job: :well).where("bhas.master_bha_id IS NULL").where("jobs.well_id = ?", @drilling_log.job.well_id).order("bhas.name ASC")

        respond_to do |format|
            format.html {
                @return_job = Job.find_by_id(cookies[:return_job])
                if @return_job.present?
                    job_ids = @drilling_log.well.jobs.select(:id).to_a
                    if job_ids.find { |j| j.id == @return_job.id }.nil?
                        @return_job = nil
                    end
                end
                if @return_job.nil?
                    @return_job = @drilling_log.job
                end
            }
            format.js {
                if params[:report].present? && params[:report] == "true" && params[:report_name].present?
                    @report_name = params[:report_name]
                    @report_id = SecureRandom.urlsafe_base64.html_safe
                    $redis.set(@report_id, '')
                    $redis.expire @report_id, 60 * 60 * 5
                    @drilling_log.delay.create_report(params[:report_name], params[:type], @report_id)
                end

            }
            format.xlsx {
                excel = drilling_log_to_excel @drilling_log
                send_data excel.to_stream.read, :filename => "Daily Activity.xlsx", :type => "application/vnd.openxmlformates-officedocument.spreadsheetml.sheet"
            }
        end

    end


end
