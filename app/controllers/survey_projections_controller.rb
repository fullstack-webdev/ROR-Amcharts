class SurveyProjectionsController < ApplicationController
    before_filter :signed_in_user, only: [:new, :create]

    include ActionView::Helpers::NumberHelper

    def new
        @survey = Survey.find_by_id(params[:survey])
        not_found unless @survey.present?

        @drilling_log = @survey.job.drilling_log

        bha = nil
        entry = @drilling_log.drilling_log_entries.where("drilling_log_entries.bha_id IS NOT NULL").last
        bha = entry.present? ? entry.bha : nil
        if bha.nil?
            bha = Bha.includes(:job).where("jobs.well_id = ?", @drilling_log.job.well_id).last
        end
        @bit_to_sensor = 0
        if bha.present?
            @bit_to_sensor = bha.bit_to_sensor.present? ? bha.bit_to_sensor : 0.0
        end
    end

    def create
        @survey = Survey.find_by_id(params[:survey])
        not_found unless @survey.present?

        @drilling_log = @survey.job.drilling_log
        @well_plans = Survey.includes(job: :well).where(:plan => true).where("wells.id = ?", @drilling_log.job.well_id).order("surveys.created_at ASC")
        if @survey.present?
            @active_well_plan = @well_plans.where("surveys.well_plan_for_survey_id = ?", @survey.id).last
        end
        if @active_well_plan.nil?
            @active_well_plan = @well_plans.last
        end

        vertical_section = @active_well_plan.present? ? @active_well_plan.vertical_section_azimuth : 0.0

        calculated_points = @survey.no_well_plan ? [] : @active_well_plan.survey_points
        calculated_points_survey = @survey.calculated_points(@survey.no_well_plan ? 0 : @active_well_plan.vertical_section_azimuth)

        last_point = calculated_points_survey.last

        bha = nil
        entry = @drilling_log.drilling_log_entries.where("drilling_log_entries.bha_id IS NOT NULL").last
        bha = entry.present? ? entry.bha : nil
        if bha.nil?
            bha = Bha.includes(:job).where("jobs.well_id = ?", @drilling_log.job.well_id).last
        end
        @bit_to_sensor = 0
        if bha.present?
            @bit_to_sensor = bha.bit_to_sensor.present? ? bha.bit_to_sensor : 0.0
        end

        case params[:type]
            when "current"
                @new_point = Survey.calculate_point(SurveyPoint.new(measured_depth: last_point.measured_depth + params["current_add"].to_f, inclination: last_point.inclination - params["current_dog_leg"].to_f, azimuth: params["current_tool_face"].to_f), last_point, vertical_section)
                @md = @new_point.measured_depth
                @inc = @new_point.inclination
                @azi = @new_point.azimuth
                @tvd = @new_point.true_vertical_depth
                @dls = @new_point.dog_leg_severity
            when "target"
                new_tvd = params["target_tvd"].to_f
                depth_change = new_tvd - last_point.true_vertical_depth
                new_md =  last_point.measured_depth + depth_change

                @new_point = Survey.calculate_point(SurveyPoint.new(measured_depth: new_md, inclination: params["target_inclination"].to_f, azimuth: params["target_azimuth"].to_f), last_point, vertical_section)
                @md = @new_point.measured_depth
                @inc = @new_point.inclination
                @azi = @new_point.azimuth
                @tvd = @new_point.true_vertical_depth
                @dls = @new_point.dog_leg_severity
            when "bit"
                @new_point = Survey.calculate_point(SurveyPoint.new(measured_depth: last_point.measured_depth + @bit_to_sensor, inclination: last_point.inclination, azimuth: last_point.azimuth), last_point, vertical_section)
                @md = @new_point.measured_depth
                @inc = @new_point.inclination
                @azi = @new_point.azimuth
                @tvd = @new_point.true_vertical_depth
                @dls = @new_point.dog_leg_severity
            when "md"
                new_md = 0
                if !params["md_add"].blank?
                    new_md = params["md_add"].to_f + last_point.measured_depth
                else
                    new_md = params["md_target"].to_f
                end
                @new_point = Survey.calculate_point(SurveyPoint.new(measured_depth: new_md, inclination: last_point.inclination, azimuth: last_point.azimuth), last_point, vertical_section)
                @md = @new_point.measured_depth
                @inc = @new_point.inclination
                @azi = @new_point.azimuth
                @dls = @new_point.dog_leg_severity
                @tvd = @new_point.true_vertical_depth
            when "tvd"
                if !params["tvd_add"].blank?
                    @md = params["tvd_add"].to_f + last_point.measured_depth
                else
                    @md = params["tvd_target"].to_f
                end

                new_md = 0
                if !params["tvd_add"].blank?
                    new_md = params["tvd_add"].to_f + last_point.true_vertical_depth
                else
                    new_tvd = params["tvd_target"].to_f

                    depth_change = new_tvd - last_point.true_vertical_depth
                    new_md =  last_point.measured_depth + depth_change
                end
                @new_point = Survey.calculate_point(SurveyPoint.new(measured_depth: new_md, inclination: last_point.inclination, azimuth: last_point.azimuth), last_point, vertical_section)
                @md = @new_point.measured_depth
                @inc = @new_point.inclination
                @azi = @new_point.azimuth
                @dls = @new_point.dog_leg_severity
                @tvd = @new_point.true_vertical_depth
        end

        @md_delta = @md - last_point.measured_depth
        @inc_delta = @inc - last_point.inclination
        @azi_delta = @azi - last_point.azimuth
        @tvd_delta = @tvd - last_point.true_vertical_depth
        @dls_delta = @dls - last_point.dog_leg_severity

        bit_point = Survey.calculate_point(SurveyPoint.new(measured_depth: @md + @bit_to_sensor, inclination: @inc, azimuth: @azi), @new_point, vertical_section)
        @md_bit = bit_point.measured_depth

    end

end
