class LwdLogsController < ApplicationController
  before_filter :signed_in_user, only: [:new, :create]

  def new
    @lwd_log = LwdLog.new

    if params[:job_id].present?
      @job = Job.find_by_id(params[:job_id])
    end

    render 'lwd_logs/new'
  end

  # def create
  #   if params[:job_id].present?
  #     @job = Job.find_by_id(params[:job_id])
  #     not_found unless @job.company == current_user.company
  #   end
  #
  #   LwdLog.transaction do
  #     file_data = params[:file_source]
  #     if file_data.respond_to?(:read)
  #       contents = file_data.read
  #     elsif file_data.respond_to?(:path)
  #       contents = File.read(file_data.path)
  #     else
  #       logger.error "Bad file_data: #{file_data.class.name}: #{file_data.inspect}"
  #     end
  #
  #     @lwd_log = LwdLog.new(params[:lwd_log])
  #     @lwd_log.job = @job
  #     @lwd_log.company = current_user.company
  #
  #     entry_lines = []
  #
  #     if contents.blank?
  #       flash[:error] = "Bad file, please select a different file and try again."
  #       render 'edit'
  #       return
  #     end
  #
  #     if !contents.blank?
  #
  #       lines = contents.split("\r\n")
  #
  #       dividers = 0
  #       lines.each_with_index do |line, index|
  #
  #       end
  #
  #       #@lwd_log.save
  #
  #     end
  #
  #     if @lwd_log.errors.any?
  #       render 'new'
  #     else
  #       redirect_to job_path(@job, anchor: "lwd_logs")
  #     end
  #   end
  # end

  def create
    @lwd_log = LwdLog.new
  end
end
