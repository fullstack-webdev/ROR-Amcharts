
# ecoding: utf-8

class JobsController < ApplicationController
  include ActionView::Helpers::NumberHelper
  include JobsHelper
  require 'net/http'
  require 'net/https'
  require 'uri'


  before_filter :signed_in_user, only: [:index, :show, :new, :create, :update, :historical_upload, :destroy, :drillview, :new_annotation, :create_annotation, :create_annotation_comment]
  set_tab :jobs

  layout :layout_selector

  def index
    @is_paged = params[:page].present?

    respond_to do |format|
      format.json {
        @jobs = nil

        if params['program'].present?
          @jobs = Job.joins(:well => {:rig => :program}).where("programs.id = :program_id", program_id: params['program'])
        else
          @jobs = current_user.jobs_list
          @jobs = Job.include_models(@jobs)
        end

        if params['rig'].present?
          @jobs = @jobs.includes(well: :rig).where("rigs.id = :rig_id", rig_id: params['rig'])
        else
          @jobs = @jobs.includes(:well)
        end

        if params['history'].present?
          search_from = Time.now - params['history'].to_i.months
          @jobs = @jobs.where("jobs.start_date > :search_from", search_from: search_from)
        end

        @jobs = @jobs.includes(:field)

        @result = []

        @jobs.each do |job|
          if !job.well.location.blank?
            j = {}
            j["id"] = job.id
            j["active"] = job.active
            j["well"] = {}
            j["well"]["name"] = job.well.name
            j["well"]["x_location"] = job.well.x_location
            j["well"]["y_location"] = job.well.y_location
            j["field"] = {}
            #j["field"]["name"] = job.field.name

            @result << j
          end
        end

        render json: @result
      }
      format.html {
        @jobs = current_user.jobs_list
        @jobs = Job.include_models(@jobs).includes(well: :drilling_log)

        #if !@is_paged
        #    if current_user.role.limit_to_assigned_jobs?
        #        @jobs = Job.include_models(@jobs).where("(jobs.status >= 1 AND jobs.status < 50) OR (jobs.status = :status_closed AND jobs.close_date >= :close_date)", status_closed: Job::COMPLETE, close_date: (Time.zone.now - 5.days))
        #    else
        #        @jobs = Job.include_models(@jobs).where("(jobs.status >= 1 AND jobs.status < 50)")
        #    end
        #else
        #    @jobs = Job.include_models(@jobs).order("jobs.created_at DESC").paginate(page: params[:page], limit: 20)
        #end

      }
      format.js {
        if params[:event_warnings] == 'true'
          @warnings = current_user.warnings_list.per_page_kaminari(params[:page]).per(EventWarning::PER_PAGE)
          @prev_time = params[:prev_time].present? ? params[:prev_time].to_time : Time.now
          @current_warnings_list = current_user.current_warnings_list
          render 'admin/company_warnings' and return
        else
          @programs = current_user.company.programs.all
          @rigs = Rig.includes(:wells).order(:name)

          if !params[:search].blank?
            @jobs = Job.search(current_user, params, current_user.company).results
          else
            @jobs = current_user.jobs_list

            @jobs = Job.include_models(@jobs).includes(well: :drilling_log)
          end
        end
      }
      format.xml {
        render xml: current_user.active_or_recently_closed_jobs,
               :methods => [:status_string, :status_percentage],
               include: {
                   :field => {except: [:created_at, :updated_at, :company_id]},
                   :well => {
                       include: {
                           :rig => {except: [:created_at, :updated_at, :company_id]}
                       },
                       except: [:created_at, :updated_at, :company_id]},
                   :district => {except: [:created_at, :updated_at, :company_id]},
                   :company => {except: [:created_at, :updated_at, :company_id]},

               }
      }
    end
  end

  require "pathname"
  def show
    set_tab :wells

    @job ||= Job.find_by_id(params[:id])
    not_found unless !@job.nil?
    not_found unless @job.company == current_user.company
    not_found unless @job.can_user_view?(current_user)

    @programs = current_user.company.programs.all

    @company_features = CompanyFeature.all.to_a

    #import @job, "#{Rails.root}/app/assets/csvs/file.xls"


    respond_to do |format|
      format.html do

      end
      format.js do

      end
      format.json do
        case params['section']
          when "process_time", "activity_summary", "operation_efficiency"
            if (!params['query_time'].nil?)
              if params['query_time'] == "-1"
                render json: @job.wits_analysis_data(-1)
              else
                render json: @job.wits_analysis_data(params['query_time'].to_datetime)
              end
              return
            end
        end

      end
      #format.pdf do
      #    render :pdf => "job.pdf",
      #           javascript_delay: 1000,
      #           :margin => {:top                => 0.0,
      #                       :bottom             => 0.0,
      #                       :left               => 0.0,
      #                       :right              => 0.0}
      #end
    end
  end

  def drillview
    set_tab :wells

    @job ||= Job.find_by_id(params[:id])
    not_found unless !@job.nil?
    not_found unless @job.company == current_user.company
    not_found unless @job.can_user_view?(current_user)

    @company_features = CompanyFeature.all.to_a
  end

  def drill_view
    @job ||= Job.find_by_id(params[:id])
    not_found unless !@job.nil?
    not_found unless @job.company == current_user.company
    not_found unless @job.can_user_view?(current_user)

    @company_features = CompanyFeature.all.to_a

    respond_to do |format|

      format.json do
        if ((params['date'] || params['depth']) && !params['zoom'].nil? && !params['uuid'].nil? && !params['interval'].nil?)
          ts = nil
          if params['date'] && params['date'] != ''
            ts = params['date'].to_i
          elsif params['depth'] && params['depth'] != ''
            ts = @job.get_date_from_depth(params['depth'].to_f)
          else
            not_found
            return
          end
          if ts.nil?
            render json: {errors: ["Depth is out of range."]}, status: 422 and return
          end

          # Incoming parameters
          date = Time.at(ts)
          zoom = params['zoom'].to_i
          interval = params['interval'].to_i
          step = params['step'].to_i

          result = {}
          result['uuid'] = params['uuid']

          # Live or not
          if (!params['live'].nil? && params['live'] == 'true')
            date = @job.last_date()
            result['last_date'] = date.to_time.to_i

            # warnings
            result['warnings'] = @job.warning_hashes

            # annotations
            result['annotations'] = @job.annotations

            # depth summary
            result['depth_summary'] = @job.get_depth_summary(zoom, step)
          else
            result['last_date'] = @job.last_date().to_time.to_i
          end

          # Out of hole range
          result['out_of_hole'] = @job.get_out_of_hole_date_summary
          # Last date of returning data
          result['date'] = date.to_time.to_i
          # Wits records
          result['wits_records'] = @job.get_wits_records(date - zoom.minutes, date, interval)
          # Activity
          result['activity_lists'] = @job.activity_lists(date - zoom.minutes, date)
          # General Activity
          result['gactivity'] = @job.get_gactivity(date)
          # Current job status
          result['job_status'] = @job.status
          # Driller notes
          result['driller_notes'] = @job.get_driller_notes(date - zoom.minutes, date)

          if result['wits_records'].present?
            bit_depth = begin
              result['wits_records'].try(:last)['bit_depth']
            rescue
              nil
            end

            # Hole cleaning
            if (!params['cleaning'].nil? && params['cleaning'].to_i == 1)
              result['hole_cleaning'] = @job.get_last_hole_cleaning(date)
            end

            # Torque+Drag specific
            if (!params['torque'].nil? && params['torque'].to_i == 1)
              result['torque'] = @job.get_torque_chart(date)

              # hole_sizes
              result['hole_sizes'] = @job.get_hole_sizes(date, bit_depth)
            end

            # ECD specific
            if (!params['ecd'].nil? && params['ecd'].to_i == 1)
              result['ecd'] = @job.get_welbore_stabillity_data(bit_depth)
            end

            # Vibration specific
            if (params['bit'].present? && params['bit'].to_i == 1)
              result['vibration'] = @job.get_vibration_data(date - (zoom + 30).minutes, date, 60)
              result['bit_score'] = @job.get_bit_score bit_depth
            end

            # Motor specific
            if (params['motor'].present? && params['motor'].to_i == 1)
              result['motor_score'] = @job.get_motor_score bit_depth
            end

            # Drilling efficiency
            if (params['bit_function'].present? && params['bit_function'].to_i == 1)
              result['efficiency'] = @job.get_drilling_efficiency bit_depth
            end
          end

          render json: result
        else
          not_found
        end
      end
    end
  end

  def historical_upload
    @job = Job.find_by_id(params[:id])
    not_found unless !@job.nil?
    not_found unless @job.company == current_user.company
    not_found unless @job.can_user_view?(current_user)

    @err = false
    begin

        @job.clean_job
        @job.status = Job::ON_JOB
        @job.time_step = 10 #params[:time_step].to_i
        if @job.save
            table_name = "wits_records#{@job.id}"
            if !(WitsRecord.connection.table_exists? table_name)
                WitsRecord.connection.execute("CREATE TABLE #{table_name} (LIKE wits_records INCLUDING DEFAULTS INCLUDING INDEXES)")
            end
        end

      s3 = AWS::S3.new
      signed_url = s3.buckets[AWSConfig['BUCKET']].objects["job" + @job.id.to_s + "/" + params[:filename]].url_for(:get, {:expires => 2.hours.from_now, :secure => true}).to_s
      req = Net::HTTP::Post.new("/api/HistoricalUpload", initheader = {'Content-Type' => 'application/json', 'Auth-Token' => '4aa9d0d9-f9c5-4f7d-9811-5dfc5ddbf9a9'})
      req.body = {JobId: @job.id, CompanyId: @job.company_id, FileUrl: signed_url}.to_json
      uri = URI.parse("https://52.5.233.28")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      res = http.request(req)
      @err = true if !res.is_a?(Net::HTTPNoContent)
    rescue => e
      puts e.message
      @err = true
    end
  end


  def report_upload
      @job = Job.find_by_id(params[:id])
      not_found unless !@job.nil?
      not_found unless @job.company == current_user.company
      not_found unless @job.can_user_view?(current_user)

      @err = false
      begin
          s3 = AWS::S3.new
          puts "Starting"
          data = s3.buckets[AWSConfig['BUCKET']].objects[(URI.unescape(params[:filepath])[1..-1]).gsub('+', ' ')].read

          tempfile = Tempfile.new(['upload', File.extname(params[:filename])], "/tmp", { encoding: Encoding::UTF_8 })
          tempfile.write data.force_encoding('utf-8')
          tempfile.close

          puts 'Importing'
          import @job, tempfile.path


      rescue => e
          puts "Error"
          puts e.message
          @err = true
      end
  end


  def get_drill_string_detail
      @job = Job.find_by_id(params[:id])
      not_found unless !@job.nil?

      @depth = (params[:hole_depth].to_f || 0).round(0)

      respond_to do |format|
          format.js {
              #if params[:hole_depth].present?
                  #@warning = EventWarning.find_by_id(params[:id])
              #end
          }
      end
  end


  def new_annotation
      @job = Job.find_by_id(params[:id])
      not_found unless !@job.nil?

      @hole_depth = (params[:hole_depth].to_f || 0).round(0)
      @time = params[:time].to_i

      render 'annotations/new_annotation'
  end


  def create_annotation
      @job = Job.find_by_id(params[:id])
      not_found unless !@job.nil?

      @hole_depth = (params[:hole_depth].gsub(",", "").to_f || 0).round(0)
      @time = params[:time].to_i


      @annotation = Annotation.new

      WitsRecord.table_name = "wits_records#{@job.id}"
      if params[:use_hole_depth] == "true"
          @annotation.start_depth = @hole_depth
          first_record = WitsRecord.select("entry_at").where("hole_depth >= ?", @hole_depth).order("entry_at ASC").limit(1).try(:first)
          @annotation.start_time = first_record.present? ? first_record.entry_at : Time.at(@time)
      else
          @annotation.start_time = Time.at(@time)
          first_record = WitsRecord.select("entry_at, hole_depth").where("entry_at >= ?",  @annotation.start_time.utc.to_s).order("entry_at ASC").limit(1).try(:first)
          @annotation.start_depth = first_record.hole_depth
      end

      #@annotation.start_depth = @hole_depth
      #@annotation.start_time = Time.at(@time)
      @annotation.job = @job
      #@annotation.company_feature = CompanyFeature::TORQUE_AND_DRAG
      @annotation.company = @job.company
      @annotation.user = current_user
      @annotation.title = params[:title]

      if @annotation.save

          comment = AnnotationComment.new
          comment.annotation = @annotation
          comment.company = @job.company
          comment.text = params[:description]
          comment.user = current_user
          comment.save

          @created = true

          render 'annotations/annotation'
      else
          render 'annotations/new_annotation'
      end
  end

  def create_annotation_comment
      @job = Job.find_by_id(params[:id])
      not_found unless !@job.nil?

      if params[:warning_id].present?
          @annotation = Annotation.find_by_event_warning_id(params[:warning_id])
          if @annotation.nil?
              @annotation = Annotation.new
              @annotation.event_warning = EventWarning.find_by_id(params[:warning_id])
              @annotation.job = @job
              @annotation.company = @job.company
              @annotation.user = current_user
              @annotation.save
          end
      else
          @annotation = Annotation.find_by_id(params[:annotation_id])
      end

      @comment = AnnotationComment.new
      @comment.annotation = @annotation
      @comment.company = @job.company
      @comment.text = params[:comment]
      @comment.user = current_user

      if @comment.save
        render 'annotations/new_annotation_comment'
      end
  end

  def show_annotation
      @job = Job.find_by_id(params[:id])
      not_found unless !@job.nil?

      @annotation = Annotation.find_by_id(params[:annotation_id])

      render 'annotations/annotation'
  end

  def get_torque
    @job = Job.find_by_id(params[:id])
    not_found unless !@job.nil?
    not_found unless @job.company == current_user.company
    not_found unless @job.can_user_view?(current_user)

    respond_to do |format|
      format.html do

      end

      format.js do

      end

      format.json do
        if (!params['date'].nil? && !params['uuid'].nil? && !params['depth'].nil?)
          date = Time.at(params['date'].to_i)
          bit_depth = params['depth'].to_f

          result = {}
          result['date'] = date.to_time.to_i;
          result['uuid'] = params['uuid'];
          result['torque'] = @job.get_torque_records(date, bit_depth)

          render json: result
        end
      end
    end
  end

  def get_ecd
    @job = Job.find_by_id(params[:id])
    not_found unless !@job.nil?
    not_found unless @job.company == current_user.company
    not_found unless @job.can_user_view?(current_user)

    respond_to do |format|
      format.html do

      end

      format.js do

      end

      format.json do
        if (!params['date'].nil? && !params['uuid'].nil?)
          date = Time.at(params['date'].to_i)

          result = {}
          result['date'] = date.to_time.to_i;
          result['uuid'] = params['uuid'];
          result['ecd'] = @job.get_welbore_stabillity_data(date)

          render json: result
        end
      end
    end
  end

  def new
    @job = Job.new
    @job.district = current_user.district

    if params.has_key?(:rig)
      @rig = Rig.find_by_id(params[:rig])
    end

    @rigs = Rig.includes(:wells).order(:name)
    # @districts = current_user.company.districts
    # @wells = Array.new

    if params.has_key?(:well)
      @job.well = Well.find_by_id(params[:well])
      @job.district = @job.well.field.district
      # @fields = @job.district.fields
      @job.field = @job.well.field
      # @wells = @job.field.wells
      @job.client = @job.well.jobs.any? ? @job.well.jobs.first.client : nil
    end
  end

  def create

    district_id = params[:job][:district_id]
    params[:job].delete(:district_id)

    field_id = params[:job][:field_id]
    params[:job].delete(:field_id)
    @field = Field.find_by_id(field_id)

    @rig = Rig.find_by_id(params[:rig_id])

    well_id = params[:job][:well_id]
    params[:job].delete(:well_id)

    @well_name = params[:well_name]

    Job.transaction do
      @job = Job.new(params[:job])
      @job.company = current_user.company
      @job.status = Job::PRE_JOB

      @rigs = Rig.includes(:wells).order(:name)

      if params[:create_rig] == "true"
        begin
          @rig = Rig.new
          @rig.name = params[:new_rig_name]
          @rig.company = current_user.company
          @rig.save
        rescue => e
          puts e.message
          raise ActiveRecord::Rollback
        end
      end

      if !@rig.present?
        @job.errors.add(:rig, "must be specified")
        raise ActiveRecord::Rollback
      end

      @job.district = District.find_by_id(district_id) || current_user.district
      @job.field = @field

      @well = Well.new
      @well.field = @field
      @well.name = @well_name
      @well.rig = @rig
      @well.company = @job.company
      @well.programs = [@rig.program] if !@rig.program.nil?
      if !@well.save
        puts @well.errors.full_messages
        @job.errors.add(:well, @well.errors.full_messages[0])
        raise ActiveRecord::Rollback
      end


      @job.well = @well


      if @job.well.present? && (@job.well.field != @job.field)
        @job.errors.add(:well, "Well does not belong to field")
      end

      if @job.save

        table_name = "wits_records#{@job.id}"
        if !(WitsRecord.connection.table_exists? table_name)
          WitsRecord.connection.execute("CREATE TABLE #{table_name} (LIKE wits_records INCLUDING DEFAULTS INCLUDING INDEXES)")
        end


        flash[:success] = "Well created"
        redirect_to job_path(@job) and return
      else
        @districts = current_user.company.districts

        if !@job.field.nil?
          @wells = @job.field.wells
        else
          @wells = Array.new
        end

        raise ActiveRecord::Rollback
      end
    end

    render 'new'
  end

  def update
    @job = Job.find_by_id(params[:id])
    not_found unless !@job.nil?
    not_found unless @job.company == current_user.company

    if params[:update_field].present? && params[:update_field] == "true" &&
        params[:field].present? && params[:value].present?
      case params[:field]
        when "inventory_notes"
          @job.update_attribute(:inventory_notes, params[:value])
        when "begin_pre_job"
          @job.update_attribute(:status, Job::PRE_JOB)
          if request.format == "html"
            redirect_to @job
          end
        when "client_id"
          @client = Client.find_by_id(params[:value])
          @job.client = @client
          @job.save
        when "drilling_company"
          @client = Client.find_by_id(params[:value])
          @job.drilling_company = @client
          @job.save
        when "directional_drilling_company"
          @client = Client.find_by_id(params[:value])
          @job.directional_drilling_company = @client
          @job.save
        when "fluids_company"
          @client = Client.find_by_id(params[:value])
          @job.fluids_company = @client
          @job.save
        when "begin_on_job"
          @job.update_attribute(:status, Job::ON_JOB)
          Activity.add(current_user, Activity::BEGIN_ON_JOB, @job, nil, @job)
          @job.delay.begin_on_job
          if request.format == "html"
            redirect_to @job
          end
        when "begin_post_job"
          @job.update_attribute(:status, Job::POST_JOB)
          Activity.add(current_user, Activity::BEGIN_POST_JOB, @job, nil, @job)
          if request.format == "html"
            redirect_to @job
          end
        when "close_job"
          @job.update_attribute(:status, Job::COMPLETE)
          Activity.add(current_user, Activity::JOB_APPROVED_TO_CLOSE, @job, nil, @job)
          @job.update_attribute(:close_date, DateTime.now)
          if request.format == "html"
            redirect_to @job
          end
        when "rating"
          @job.update_attribute(:rating, params[:value])
          Activity.add(self.current_user, Activity::JOB_RATING, @job, @job.rating.to_i, @job)
          @rating_updated = true
        when "no_well_plan"
          survey = @job.survey
          if survey
            @survey = Survey.find_by_id(survey.id)
            @survey.update_attribute(:no_well_plan, true)
            redirect_to job_path(@job, anchor: "surveys")
          end
      end
    else
      if params["start_date"].present?
        start = @job.start_date
        date = Date.today
        begin
          date = Date.strptime(params["start_date"], '%m/%d/%Y')
        rescue
          date = Date.strptime(params["start_date"], '%m-%d-%Y')
        end

        @job.update_attribute(:start_date, date.to_time_in_current_zone)
        Activity.add(self.current_user, Activity::START_DATE, @job, @job.start_date, @job)

        if start.present? && start != @job.start_date
          change = @job.start_date - start

        else
          @update_calendar = true
        end
      end
    end
  end

  def destroy

    @job = Job.find_by_id(params[:id])
    not_found unless !@job.nil?
    not_found unless @job.company == current_user.company
    not_found unless current_user.role != UserRole::ROLE_FIELD_ENGINEER
    Well.transaction do


      well = @job.well

      well.jobs.each do |current_job|
        # WitsRecord.table_name = "wits_records#{current_job.id}"
        table_name = "wits_records#{current_job.id}"
        if WitsRecord.connection.table_exists? table_name
          WitsRecord.connection.execute("drop table wits_records#{current_job.id}")
        end
        ActiveRecord::Base.connection.execute("delete from wits_activity_lists where job_id = " + current_job.id.to_s)
        ActiveRecord::Base.connection.execute("delete from wits_category_allocs where job_id = " + current_job.id.to_s)
        ActiveRecord::Base.connection.execute("delete from wits_category_lists where job_id = " + current_job.id.to_s)
        ActiveRecord::Base.connection.execute("delete from wits_data where job_id = " + current_job.id.to_s)
        ActiveRecord::Base.connection.execute("delete from wits_gactivities where job_id = " + current_job.id.to_s)
        ActiveRecord::Base.connection.execute("delete from drilling_logs where job_id = " + current_job.id.to_s)
        ActiveRecord::Base.connection.execute("delete from programs_wells where well_id = " + current_job.well.id.to_s)
        ActiveRecord::Base.connection.execute("delete from event_warnings where job_id = " + current_job.id.to_s)
        ActiveRecord::Base.connection.execute("delete from torque_drag_data where job_id = " + current_job.id.to_s)
        ActiveRecord::Base.connection.execute("delete from torque_drag_charts where job_id = " + current_job.id.to_s)
        # ActiveRecord::Base.connection.execute("delete from wits_activity_lists where job_id = " + current_job.id)

        current_job.destroy
      end
      well.destroy
      flash[:success] = 'Well deleted.'
    end

    redirect_to wells_path
  end

  def rig
    @job = Job.find_by_id(params[:id])
    not_found unless !@job.nil?

    respond_to do |format|
      format.html do

      end
      format.js do

      end
    end
  end

  def layout_selector
    case params[:action]
      when 'rig'
        "blank"
      else
        "application"
    end
  end

  def offset_well
    @job = Job.includes(:well).find_by_id(params[:id])
    not_found unless !@job.nil?
    not_found unless @job.company == current_user.company
  end

  def set_offset_well
    @job = Job.find_by_id(params[:id])
    not_found unless !@job.nil?
    not_found unless @job.company == current_user.company

    @well = Well.find_by_id(@job.well_id)
    not_found unless !@well.nil?

    if params[:offset_well_id].present?
      @well.offset_well_id = params[:offset_well_id]
      @well.save

      @offset_well = Well.find_by_id(params[:offset_well_id])
      not_found unless !@offset_well.nil?
    end
  end

  def create_hole_string
    respond_to do |format|
      format.json do
        entry_at = Time.at(params[:entry_at].to_i) unless params[:entry_at].nil?
        entry_at ||= nil

        job = Job.find_by_id(params[:id])
        not_found unless !job.nil?

        arr_ds = params[:drilling_strings] || []
        arr_hs = params[:hole_sizes] || []
        arr_casing = params[:casings] || []
        hash_bit = params[:bit] || []

        @success = true
        @err_msg = {}
        ActiveRecord::Base.transaction do

          if entry_at.nil?
            DrillingString.where(:job_id => job.id, :entry_at => nil, :depth_from => params[:depth_from], :depth_to => params[:depth_to]).destroy_all
            Bit.where(:job_id => job.id, :entry_at => nil, :depth_from => params[:depth_from], :depth_to => params[:depth_to]).destroy_all
          else
            DrillingString.where(:job_id => job.id, :entry_at => entry_at).destroy_all
            HoleSize.where(:job_id => job.id, :entry_at => entry_at).destroy_all
            Bit.where(:job_id => job.id, :entry_at => entry_at).destroy_all
          end

          arr_ds.each_with_index do |item, index|
            ds = DrillingString.new
            ds.position = index
            ds.outer_diameter = item["outer_diameter"].to_f.convert_default(:in, company_unit)
            ds.type = item["type"]
            ds.inner_diameter = item["inner_diameter"].to_f.convert_default(:in, company_unit)
            ds.weight = item["weight"].to_f.convert_default(:lbm__ft, company_unit)
            ds.length = item["length"].to_f.convert_default(:ft, company_unit)
            if entry_at.nil?
              ds.depth_from = params["depth_from"]
              ds.depth_to = params["depth_to"]
            end
            ds.job = job
            ds.company = current_user.company
            ds.entry_at = entry_at
            if !ds.save
              puts ds.errors.full_messages
              @err_msg['drilling_string'] = ds.errors
              @success = false
            end
          end

          arr_hs.each do |item|
            hs = HoleSize.new
            hs.diameter = item['diameter'].to_f.convert_default(:in, company_unit)
            hs.depth = item['depth'].to_f.convert_default(:ft, company_unit)
            hs.job = job
            hs.company = current_user.company
            hs.entry_at = entry_at
            if !hs.save
              puts hs.errors.full_messages
              @err_msg['hole_size'] = hs.errors
              @success = false
            end
          end

          Casing.where(:job_id => job.id, :entry_at => entry_at).destroy_all

          arr_casing.each do |item|
            casing = Casing.new
            casing.inner_diameter = item['inner_diameter'].to_f.convert_default(:in, company_unit)
            casing.length = item['length'].to_f.convert_default(:ft, company_unit)
            casing.depth_from = item['depth_from'].to_f.convert_default(:ft, company_unit)
            casing.depth_to = item['depth_to'].to_f.convert_default(:ft, company_unit)
            casing.job = job
            casing.company = current_user.company
            casing.entry_at = entry_at
            if !casing.save
              puts casing.errors.full_messages
              @err_msg['casing'] = casing.errors
              @success = false
            end
          end

          bit = Bit.new
          bit.size = hash_bit['size'].to_f.convert_default(:in, company_unit)
          bit.make = hash_bit['make']
          bit.jets = hash_bit['jets']
          bit.nozzle_size = hash_bit['nozzle_size'].to_f.convert_default(:in, company_unit)
          bit.tfa = hash_bit['tfa'].to_f.convert_default(:in2, company_unit)
          bit.hhsi = hash_bit['hhsi']
          bit.serial_no = hash_bit['serial_no']
          bit.job = job
          bit.company = current_user.company
          bit.entry_at = entry_at
          if entry_at.nil?
            bit.depth_from = params["depth_from"]
            bit.depth_to = params["depth_to"]
          end
          if !bit.save
            puts bit.errors.full_messages
            @err_msg['bit'] = bit.errors
            @success = false
          end


        end

        entry_at_display = nil
        if !entry_at.nil?
          days = job.get_hole_string_days
          @days = days.collect { |x| {entry_at: x.entry_at.strftime("%A %m/%d"), ts: x.entry_at.to_i} }
          entry_at_display = entry_at.strftime("%A %m/%d")
        else
          @depth_ranges = job.get_hole_string_depth
        end
        @days ||= nil

        render json: {valid: @success, days: @days, entry_at: params[:entry_at], entry_at_display: entry_at_display, error: @err_msg, depth_ranges: @depth_ranges}
      end
    end
  end

  def get_default_conf
    respond_to do |format|
      format.js do
        job = Job.find_by_id(params[:id])
        not_found unless !job.nil?

        @conf = {}

        @conf['drilling_strings'] = DrillingString.where(:job_id => params[:id], :default => true)
        @conf['casings'] = Casing.where(:job_id => params[:id], :default => true)
        @conf['hole_sizes'] = HoleSize.where(:job_id => params[:id], :default => true)
        @conf['bit'] = Bit.where(:job_id => params[:id], :default => true).try(:first)
        @conf['fluid'] = Fluid.where(:job_id => params[:id], :default => true).try(:first)

        @conf['well_name'] = job.well.name

        render
      end
    end
  end

  def set_default_conf
    respond_to do |format|
      format.json do
        job = Job.find_by_id(params[:id])
        not_found unless !job.nil?

        arr_ds = params[:drilling_strings] || []
        arr_hs = params[:hole_sizes] || []
        arr_casing = params[:casings] || []
        hash_bit = params[:bit] || {}
        hash_fluid = params[:fluid] || {}

        @success = true
        @err_msg = {}
        ActiveRecord::Base.transaction do

          DrillingString.where(:job_id => job.id, :default => true).destroy_all

          arr_ds.each do |item|
            ds = DrillingString.new
            ds.outer_diameter = item["outer_diameter"]
            ds.type = item["type"]
            ds.inner_diameter = item["inner_diameter"]
            ds.weight = item["weight"].to_f.convert_default(:lbm__ft, company_unit)
            ds.length = item["length"].to_f.convert_default(:ft, company_unit)
            ds.job = job
            ds.company = current_user.company
            ds.default = true
            if !ds.save
              puts ds.errors.full_messages
              @err_msg['drilling_string'] = ds.errors
              @success = false
            end
          end

          HoleSize.where(:job_id => job.id, :default => true).destroy_all

          arr_hs.each do |item|
            hs = HoleSize.new
            hs.diameter = item['diameter']
            hs.depth = item['depth'].to_f.convert_default(:ft, company_unit)
            hs.job = job
            hs.company = current_user.company
            hs.default = true
            if !hs.save
              puts hs.errors.full_messages
              @err_msg['hole_size'] = hs.errors
              @success = false
            end
          end

          Casing.where(:job_id => job.id, :default => true).destroy_all

          arr_casing.each do |item|
            casing = Casing.new
            casing.inner_diameter = item['inner_diameter']
            casing.length = item['length'].to_f.convert_default(:ft, company_unit)
            casing.depth_from = item['depth_from'].to_f.convert_default(:ft, company_unit)
            casing.depth_to = item['depth_to'].to_f.convert_default(:ft, company_unit)
            casing.job = job
            casing.company = current_user.company
            casing.default = true
            if !casing.save
              puts casing.errors.full_messages
              @err_msg['casing'] = casing.errors
              @success = false
            end
          end

          Bit.where(:job_id => job.id, :default => true).destroy_all

          bit = Bit.new
          bit.size = hash_bit['size']
          bit.make = hash_bit['make']
          bit.jets = hash_bit['jets']
          bit.nozzle_size = hash_bit['nozzle_size']
          bit.tfa = hash_bit['tfa']
          bit.hhsi = hash_bit['hhsi']
          bit.serial_no = hash_bit['serial_no']
          bit.job = job
          bit.company = current_user.company
          bit.default = true
          if !bit.save
            puts bit.errors.full_messages
            @err_msg['bit'] = bit.errors
            @success = false
          end

          Fluid.where(:job_id => job.id, :default => true).destroy_all

          fluid = Fluid.new
          fluid.type = hash_fluid[:type]
          fluid.density = hash_fluid[:density]
          fluid.funnel_viscosity = hash_fluid[:funnel_viscosity]
          fluid.filtrate = hash_fluid[:filtrate]
          fluid.pv = hash_fluid[:pv]
          fluid.yp = hash_fluid[:yp]
          fluid.ph = hash_fluid[:ph]
          fluid.mud_cake_thickness = hash_fluid[:mud_cake_thickness]
          fluid.high_gravity_densities = hash_fluid[:high_gravity_densities]
          fluid.low_gravity_densities = hash_fluid[:low_gravity_densities]
          fluid.high_gravity_volume = hash_fluid[:high_gravity_volume]
          fluid.low_gravity_volume = hash_fluid[:low_gravity_volume]
          fluid.drilled_solids_volume = hash_fluid[:drilled_solids_volume]
          fluid.rpm600 = hash_fluid[:rpm600]
          fluid.rpm300 = hash_fluid[:rpm300]
          fluid.rpm200 = hash_fluid[:rpm200]
          fluid.rpm100 = hash_fluid[:rpm100]
          fluid.rpm6 = hash_fluid[:rpm6]
          fluid.rpm3 = hash_fluid[:rpm3]
          fluid.seconds10 = hash_fluid[:seconds10]
          fluid.minutes10 = hash_fluid[:minutes10]
          fluid.water_volume = hash_fluid[:water_volume]
          fluid.oil_volume = hash_fluid[:oil_volume]
          fluid.solid_volume = hash_fluid[:solid_volume]
          fluid.methylene_blue = hash_fluid[:methylene_blue]
          fluid.drilling_fluid = hash_fluid[:drilling_fluid]
          fluid.bentonite = hash_fluid[:bentonite]
          fluid.total_cl = hash_fluid[:total_cl]
          fluid.k_acetate = hash_fluid[:k_acetate]
          fluid.potassium_bromide = hash_fluid[:potassium_bromide]
          fluid.sodium_bromide = hash_fluid[:sodium_bromide]
          fluid.calcium_bromide = hash_fluid[:calcium_bromide]
          fluid.potassium_formate = hash_fluid[:potassium_formate]
          fluid.sodium_formate = hash_fluid[:sodium_formate]
          fluid.cesium_formate = hash_fluid[:cesium_formate]
          fluid.ammonium_chloride = hash_fluid[:ammonium_chloride]
          fluid.kci = hash_fluid[:kci]
          fluid.k2so4 = hash_fluid[:k2so4]
          fluid.cacl2 = hash_fluid[:cacl2]
          fluid.mgcl2 = hash_fluid[:mgcl2]
          fluid.brine_density = hash_fluid[:brine_density]
          fluid.job = job
          fluid.company = current_user.company
          fluid.default = true
          if !fluid.save
            puts fluid.errors.full_messages
            @err_msg['fluid'] = fluid.errors
            @success = false
          end
        end

        render json: {valid: @success, error: @err_msg}
      end
    end
  end

  def get_hole_string
    respond_to do |format|
      format.json {
        job = Job.find_by_id(params[:id])
        not_found unless !job.nil?

        date = Time.at(params[:date].to_i) unless params[:date].nil?
        date ||= nil

        not_found if date.nil? and params[:depth_from].nil? and params[:depth_to].nil?

        result = job.get_hole_string(date, params[:depth_from].to_f, params[:depth_to].to_f)

        render json: result
      }
    end
  end

  def create_fluids
    respond_to do |format|
      format.json do
        entry_at = params[:entry_at].nil? ? nil : Time.at(params[:entry_at].to_i)

        job = Job.find_by_id(params[:id])
        not_found unless !job.nil?

        @success = true
        ActiveRecord::Base.transaction do
          if entry_at.nil?
            Fluid.where(:job_id => job.id, :entry_at => entry_at, :in_depth => params[:in_depth]).destroy_all
          else
            Fluid.where(:job_id => job.id, :entry_at => entry_at).destroy_all
          end

          fluid = Fluid.new
          fluid.type = params[:type]
          fluid.density = params[:density].to_f.convert_default(:ppg, company_unit)
          fluid.funnel_viscosity = params[:funnel_viscosity]
          fluid.filtrate = params[:filtrate]
          fluid.pv = params[:pv]
          fluid.yp = params[:yp]
          fluid.ph = params[:ph]
          fluid.mud_cake_thickness = params[:mud_cake_thickness].to_f.convert_default(:in, company_unit)
          fluid.high_gravity_densities = params[:high_gravity_densities].to_f.convert_default(:ppg, company_unit)
          fluid.low_gravity_densities = params[:low_gravity_densities].to_f.convert_default(:ppg, company_unit)
          fluid.high_gravity_volume = params[:high_gravity_volume]
          fluid.low_gravity_volume = params[:low_gravity_volume]
          fluid.drilled_solids_volume = params[:drilled_solids_volume]
          fluid.rpm600 = params[:rpm600]
          fluid.rpm300 = params[:rpm300]
          fluid.rpm200 = params[:rpm200]
          fluid.rpm100 = params[:rpm100]
          fluid.rpm6 = params[:rpm6]
          fluid.rpm3 = params[:rpm3]
          fluid.seconds10 = params[:seconds10]
          fluid.minutes10 = params[:minutes10]
          fluid.water_volume = params[:water_volume]
          fluid.oil_volume = params[:oil_volume]
          fluid.solid_volume = params[:solid_volume]
          fluid.methylene_blue = params[:methylene_blue]
          fluid.drilling_fluid = params[:drilling_fluid]
          fluid.bentonite = params[:bentonite]
          fluid.total_cl = params[:total_cl]
          fluid.k_acetate = params[:k_acetate]
          fluid.potassium_bromide = params[:potassium_bromide]
          fluid.sodium_bromide = params[:sodium_bromide]
          fluid.calcium_bromide = params[:calcium_bromide]
          fluid.potassium_formate = params[:potassium_formate]
          fluid.sodium_formate = params[:sodium_formate]
          fluid.cesium_formate = params[:cesium_formate]
          fluid.ammonium_chloride = params[:ammonium_chloride]
          fluid.kci = params[:kci]
          fluid.k2so4 = params[:k2so4]
          fluid.cacl2 = params[:cacl2]
          fluid.mgcl2 = params[:mgcl2]
          fluid.brine_density = params[:brine_density]
          fluid.job = job
          fluid.company = current_user.company
          fluid.entry_at = entry_at
          if entry_at.nil?
            fluid.in_depth = params[:in_depth]
          end
          if !fluid.save
            puts fluid.errors.full_messages
            @success = false
          end
        end

        entry_at_display = ''

        if entry_at.nil?
          @depths = job.get_fluids_depths
        else
          days = job.get_fluids_days
          @days = days.collect { |x| {entry_at: x.entry_at.strftime("%A %m/%d"), ts: x.entry_at.to_i} }
          entry_at_display = entry_at.strftime("%A %m/%d")
        end

        render json: {valid: @success, days: @days, entry_at: entry_at_display, depths: @depths}
      end
    end
  end

  def get_fluids
    respond_to do |format|
      format.json {
        job = Job.find_by_id(params[:id])
        not_found unless !job.nil?

        entry_at = params[:date].nil? ? nil : Time.at(params[:date].to_i)

        if entry_at.nil?
          result = Fluid.where(:job_id => job.id, :entry_at => entry_at, :in_depth => params[:depth]).first
        else
          result = Fluid.where(:job_id => job.id, :entry_at => entry_at).first
        end

        render json: result
      }
    end
  end

  def new_conf_hole_string
    @default_bit = Bit.where('job_id = ? AND bits.default = ?', params[:id], true).try(:first)
    @default_casing = Casing.where('job_id = ? AND casings.default = ?', params[:id], true)
    @default_drilling_string = DrillingString.where('job_id = ? AND drilling_strings.default = ?', params[:id], true)
    @default_hole_size = HoleSize.where('job_id = ? AND hole_sizes.default = ?', params[:id], true)
    @depth_based_casing = Casing.where(:job_id => params[:id], :entry_at => nil)
  end

  def edit_conf_hole_string
    job = Job.find_by_id(params[:id])
    not_found unless !job.nil?
    date = Time.at(params[:date].to_i) unless params[:date].nil?
    depth_from = params[:depth_from] || 0
    depth_to = params[:depth_to] || 0

    if date.present?
      @drilling_strings = DrillingString.where(:job_id => job.id, :entry_at => date).order(:position)
      @casings = Casing.where(:job_id => job.id, :entry_at => date)
      @bit = Bit.where(:job_id => job.id, :entry_at => date).first
      @date = params[:date]
    else
      @drilling_strings = DrillingString.where(:job_id => job.id, :entry_at => nil, :depth_from => depth_from, :depth_to => depth_to).order(:position)
      @casings = Casing.where(:job_id => job.id, :entry_at => date)
      @bit = Bit.where(:job_id => job.id, :entry_at => nil, :depth_from => depth_from, :depth_to => depth_to).first
      @depth_from = params[:depth_from]
      @depth_to = params[:depth_to]
    end
  end

  def delete_conf_hole_string
    respond_to do |format|
      format.json {
        job = Job.find_by_id(params[:id])
        not_found unless !job.nil?

        entry_at = Time.at(params[:date].to_i) unless params[:date].nil?
        depth_from = params[:depth_from] || 0
        depth_to = params[:depth_to] || 0

        puts params.inspect

        if entry_at.present?
          ActiveRecord::Base.transaction do
            DrillingString.where(:job_id => job.id, :entry_at => entry_at).destroy_all
            Casing.where(:job_id => job.id, :entry_at => entry_at).destroy_all
            Bit.where(:job_id => job.id, :entry_at => entry_at).destroy_all
          end
        else
          ActiveRecord::Base.transaction do
            DrillingString.where(:job_id => job.id, :entry_at => nil, :depth_from => depth_from, :depth_to => depth_to).destroy_all
            if DrillingString.where(:job_id => job.id, :entry_at => nil).blank?
              Casing.where(:job_id => job.id, :entry_at => nil).destroy_all
            end
            Bit.where(:job_id => job.id, :entry_at => nil, :depth_from => depth_from, :depth_to => depth_to).destroy_all
          end
        end

        render json: nil
      }
    end
  end

  def new_conf_fluids
    @default_fluids = Fluid.where('job_id = ? AND fluids.default = ?', params[:id], true).try(:first)
  end

  def import_bha
    job = Job.find_by_id(params[:id])
    not_found unless !job.nil?

    if params[:file].nil?
      flash[:info] = "Please select configuration file to upload."
      redirect_to job_url(job) + '#import'
      return
    end

    ActiveRecord::Base.transaction do
      DrillingString.where(:job_id => job.id, :entry_at => nil).destroy_all
      Casing.where(:job_id => job.id, :entry_at => nil).destroy_all
      Bit.where(:job_id => job.id, :entry_at => nil).destroy_all
      Fluid.where(:job_id => job.id, :entry_at => nil).destroy_all
      @success = job.import_bha(params[:file])
      ActiveRecord::Rollback unless @success
    end

    if @success
      flash[:success] = "Configuration is successfully imported!"
    else
      flash[:error] = "Configuration can not be imported at the moment. Please try again later."
    end
    redirect_to job_url(job) + '#import'
  end

  def import_survey
    job = Job.find_by_id(params[:id])
    not_found unless !job.nil?

    if params[:file].nil?
      flash[:info] = "Please select configuration file to upload."
      redirect_to job_url(job) + '#import'
      return
    end

    ActiveRecord::Base.transaction do
      @success = job.import_survey(params[:file])
      ActiveRecord::Rollback unless @success
    end

    if @success
      flash[:success] = "Configuration is successfully imported!"
    else
      flash[:error] = "Configuration can not be imported at the moment. Please try again later."
    end
    redirect_to job_url(job) + '#import'
  end
end