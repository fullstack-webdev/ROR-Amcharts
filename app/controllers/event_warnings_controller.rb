class EventWarningsController < ApplicationController
  before_filter :signed_in_user, only: [:index, :show, :new, :create, :update, :destroy, :get_warning_detail]


  def get_warning_detail
    respond_to do |format|
      format.js {
        if params[:id].present?
          @warning = EventWarning.find_by_id(params[:id])
        end
      }
    end
  end

  def destroy
    @warning = EventWarning.find_by_id(params[:id])
    not_found unless @warning.present?

    @warning.destroy
    redirect_to :back
  end

  def create
    respond_to do |format|
      format.js {
        job = Job.find_by_id(params[:job_id])
        not_found if job.nil?
        warning_type = EventWarningType.find_by_id(params[:warning_id])
        not_found if warning_type.nil?
        company = Company.find_by_id(params[:company_id])
        not_found if company.nil?

        depth_from = 0
        depth_to = nil

        date_from = DateTime.strptime(params[:date_from], '%m/%d/%Y %H:%M:%S')
        date_to = nil

        result = WitsActivityList.where('job_id = ? AND start_time <= ? AND end_time >= ?', job.id, date_from.utc, date_from.utc).order('end_time DESC').select('bit_depth').limit(1)
        if result.empty?
          @success = false
          @error = "Start time is out of range. Between #{job.start_date} - #{job.end_date}"
          render and return
        else
          depth_from = result[0].bit_depth
        end

        if params[:date_to].present?
          date_to = DateTime.strptime(params[:date_to], '%m/%d/%Y %H:%M:%S')

          if date_from > date_to
            @success = false
            @error = "Please set the time range correctly."
            render and return
          end

          result = WitsActivityList.where('job_id = ? AND start_time <= ? AND end_time >= ?', job.id, date_to.utc, date_to.utc).order('end_time DESC').select('bit_depth').limit(1)
          if result.empty?
            date_to = nil
          else
            depth_to = result[0].bit_depth
          end
        end

        warning = EventWarning.new
        warning.opened_at = date_from
        warning.closed_at = date_to
        warning.job = job
        warning.company = company
        warning.event_warning_type = warning_type
        warning.depth_from = depth_from
        warning.depth_to = depth_to
        if warning.save
          @success = true
          @company = company
          @warnings = @company.warnings_list.per_page_kaminari(params[:page]).per(EventWarning::PER_PAGE)
          @prev_time = Time.now
          @current_warnings_list = @company.current_warnings_list
        else
          @success = false
          @error = warning.errors.full_messages.join("<br>").html_safe
        end
      }
    end
  end
end