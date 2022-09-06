class SurveysController < ApplicationController
    before_filter :signed_in_user, only: [:index, :show, :new, :create, :edit, :update]

    include SurveysHelper

    def index
        if params[:job].present?
            @job = Job.find_by_id(params[:job])
            not_found unless !@job.nil?

            @survey = Survey.includes(job: :well).where(:plan => false).where("wells.id = ?", @job.well_id).first
            if @survey.nil?
                @survey = Survey.new(plan: false)
                @survey.company = current_user.company
                @survey.job = @job
                @survey.save
                redirect_to @survey
            else
                redirect_to @survey
            end
        end
    end

    def show
        @survey = Survey.find(params[:id])
        not_found unless @survey.present?

        respond_to do |format|
            format.xlsx {
                @active_well_plan = Survey.includes(job: :well).where(:plan => true).where("wells.id = ?", @survey.job.well_id).first
                excel = survey_to_excel @active_well_plan, @survey
                send_data excel.to_stream.read, :filename => "Survey (#{@survey.job.name}).xlsx", :type => "application/vnd.openxmlformates-officedocument.spreadsheetml.sheet"
            }
            format.js {

            }
            format.all {
                if !@survey.plan?
                    @active_well_plan = Survey.includes(job: :well).where(:plan => true).where("wells.id = ?", @survey.job.well_id).first
                    render 'surveys/show_entry'
                else
                    render 'surveys/show'
                end
            }
        end
    end

    def new
        if params[:new_side_track].present? && params[:new_side_track] == "true"
            @drilling_log = DrillingLog.find_by_id(params[:drilling_log])
            last_survey = Survey.includes(job: :well).where(:plan => false).where("wells.id = ?", @drilling_log.job.well_id).last
            @survey = Survey.new(name: (last_survey.name.to_i + 1).to_s, plan: false)
            @survey.company = current_user.company
            @survey.job = last_survey.job
            @survey.save
            redirect_to drilling_log_path(@drilling_log, anchor: "survey", survey: @survey.id)
        else
            @survey = Survey.new
            @survey_points = ''
            @import_tie_on = true
            @plan = true

            if params[:job_id].present?
                @job = Job.find_by_id(params[:job_id])
            end

            if params["modal"].present? && params["modal"] == "true"
                render 'surveys/new_modal'
            else
                render 'surveys/new'
            end
        end
    end

    def create
        if params[:job_id].present?
            @job = Job.find_by_id(params[:job_id])
            not_found unless @job.company == current_user.company
        end

        Survey.transaction do

            file_data = params[:file_source]
            if file_data.respond_to?(:read)
                contents = file_data.read
            elsif file_data.respond_to?(:path)
                contents = File.read(file_data.path)
            else
                logger.error "Bad file_data: #{file_data.class.name}: #{file_data.inspect}"
            end

            @survey = Survey.new(params[:survey])
            @survey.job = @job
            @survey.company = current_user.company
            @survey.plan = true
            @survey.north_type = Survey::GRID

            begin
                @survey.name = File.basename(file_data.original_filename, '.*')
            rescue
            end

            entry_lines = []

            if contents.blank?
                flash[:error] = "Bad file, please select a different file and try again."
                render 'edit'
                return
            end

            compass = true
            if !contents.blank?
                if contents.start_with?("H")
                    compass = false
                    lines = contents.split("\r\n")
                    lines.each_with_index do |line, index|
                        if !line.start_with?('H')
                            entry_lines << line
                        elsif line.start_with?('H VSECT ANGLE')
                            @survey.vertical_section_azimuth = line[1..-1].split(':')[1].strip!
                        end
                    end
                else
                    lines = contents.split("\r\n")

                    dividers = 0
                    lines.each_with_index do |line, index|
                        if line.start_with?(' ===')
                            dividers += 1
                        else
                            if line.start_with?('VSect. Azimuth')
                                @survey.vertical_section_azimuth = line.split(':')[1].strip!
                            elsif dividers >= 2
                                entry_lines << line
                            end
                        end
                    end
                end

                @survey.save

                last_point = nil
                entry_lines.each_with_index do |line, index|
                    parts = line.gsub('/\s+/m', ' ').strip.split(' ')
                    survey_point = SurveyPoint.new
                    survey_point.company = current_user.company
                    survey_point.user = current_user
                    survey_point.user_name = current_user.name
                    survey_point.survey = @survey
                    survey_point.comment = nil

                    if compass
                        survey_point.measured_depth = parts[1].to_d
                        survey_point.inclination = parts[2].to_d
                        survey_point.azimuth = parts[3].to_d
                        survey_point.course_length = parts[4].to_d
                        survey_point.true_vertical_depth = parts[5].to_d
                        survey_point.vertical_section = parts[6].to_d
                        survey_point.north_south = parts[7].to_d
                        survey_point.east_west = parts[8].to_d
                        survey_point.closure_distance = parts[9].to_d
                        survey_point.closure_angle = parts[10].to_d
                        survey_point.dog_leg_severity = parts[11].to_d
                    else
                        survey_point.measured_depth = parts[0].to_d
                        survey_point.inclination = parts[1].to_d
                        survey_point.azimuth = parts[2].to_d
                        survey_point.true_vertical_depth = parts[3].to_d
                        survey_point.north_south = parts[4].to_d
                        survey_point.east_west = parts[5].to_d

                        survey_point = Survey.calculate_point survey_point, last_point, @survey.vertical_section_azimuth
                    end

                    survey_point.save
                    survey_point
                    last_point = survey_point
                end

                if @survey.survey_points.any?
                    drilling_log = DrillingLog.includes(job: :well).where("wells.id = ?", @survey.job.well_id).first
                    if drilling_log.present?
                        drilling_log.update_attribute(:td_depth, @survey.survey_points.last.measured_depth)
                    end
                end

                @actual_survey = Survey.includes(:job).where(:plan => false).where("jobs.well_id = ?", @survey.job.well_id).first
                if @actual_survey.present? && @actual_survey.no_well_plan
                    @actual_survey.no_well_plan = false
                    @actual_survey.save
                end
            end

            if @survey.errors.any?
                render 'new'
            else
                if params[:active_well].present? && params[:active_well] == "true"
                    render 'surveys/create_modal'
                else
                    redirect_to job_path(@job, anchor: "well_plan")
                end
            end
        end
    end


    def edit
        @survey = Survey.find(params[:id])
        @survey_points = ''
        @import_tie_on = true
        @plan = true
    end

    def update
        @survey = Survey.find(params[:id])
        @plan = true

        @surveys = Survey.includes(job: :well).where(:plan => false).where("wells.id = ?", @survey.job.well_id).order("surveys.created_at ASC")
        if @surveys.count > 1
            old_survey = @survey
            @survey = Survey.new
            @survey.company = current_user.company
            @survey.job = old_survey.job
            @survey.plan = true
            @survey.north_type = Survey::GRID
        end

        SurveyPoint.transaction do

            file_data = params[:file_source]
            if file_data.respond_to?(:read)
                contents = file_data.read
            elsif file_data.respond_to?(:path)
                contents = File.read(file_data.path)
            else
                logger.error "Bad file_data: #{file_data.class.name}: #{file_data.inspect}"
            end

            begin
                @survey.name = File.basename(file_data.original_filename, '.*')
            rescue
            end

            @survey.north_type = Survey::GRID
            @survey.well_plan_for_survey = Survey.find_by_id(params[:track_id])

            entry_lines = []

            if contents.blank?
                flash[:error] = "Bad file, please select a different file and try again."
                render 'edit'
                return
            end

            compass = true
            if contents.start_with?("H")
                compass = false
                lines = contents.split("\r\n")
                lines.each_with_index do |line, index|
                    if !line.start_with?('H')
                        entry_lines << line
                    elsif line.start_with?('H VSECT ANGLE')
                        @survey.vertical_section_azimuth = line[1..-1].split(':')[1].strip!
                    end
                end
            else
                lines = contents.split("\r\n")

                dividers = 0
                lines.each_with_index do |line, index|
                    if line.start_with?(' ===')
                        dividers += 1
                    else
                        if line.start_with?('VSect. Azimuth')
                            @survey.vertical_section_azimuth = line.split(':')[1].strip!
                        elsif dividers >= 2
                            entry_lines << line
                        end
                    end
                end
            end

            @survey.save


            @survey.survey_points.each do |sp|
                sp.destroy
            end

            last_point = nil
            entry_lines.each_with_index do |line, index|
                parts = line.gsub('/\s+/m', ' ').strip.split(' ')
                survey_point = SurveyPoint.new
                survey_point.company = current_user.company
                survey_point.user = current_user
                survey_point.user_name = current_user.name
                survey_point.survey = @survey
                survey_point.comment = nil

                if compass
                    survey_point.measured_depth = parts[1].to_d
                    survey_point.inclination = parts[2].to_d
                    survey_point.azimuth = parts[3].to_d
                    survey_point.course_length = parts[4].to_d
                    survey_point.true_vertical_depth = parts[5].to_d
                    survey_point.vertical_section = parts[6].to_d
                    survey_point.north_south = parts[7].to_d
                    survey_point.east_west = parts[8].to_d
                    survey_point.closure_distance = parts[9].to_d
                    survey_point.closure_angle = parts[10].to_d
                    survey_point.dog_leg_severity = parts[11].to_d
                else
                    survey_point.measured_depth = parts[0].to_d
                    survey_point.inclination = parts[1].to_d
                    survey_point.azimuth = parts[2].to_d
                    survey_point.true_vertical_depth = parts[3].to_d
                    survey_point.north_south = parts[4].to_d
                    survey_point.east_west = parts[5].to_d

                    survey_point = Survey.calculate_point survey_point, last_point, @survey.vertical_section_azimuth
                end

                survey_point.save
                survey_point
                last_point = survey_point
            end

            @actual_survey = Survey.includes(:job).where(:plan => false).where("jobs.well_id = ?", @survey.job.well_id).first
            if @actual_survey.present? && @actual_survey.no_well_plan
                @actual_survey.no_well_plan = false
                @actual_survey.save
            end
        end

        if @survey.errors.any?
            render 'edit'
        else
            redirect_to @survey
        end
    end

end
