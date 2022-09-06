class SurveyPointsController < ApplicationController
    before_filter :signed_in_user, only: [:new, :create, :edit, :update, :destroy]

    def new
        @survey_point = SurveyPoint.new
    end

    def create
        survey_id = params[:survey_point][:survey_id]
        params[:survey_point].delete(:survey_id)

        depth = params[:survey_point][:measured_depth]
        params[:survey_point].delete(:measured_depth)

        @survey = Survey.find_by_id(survey_id)
        @well_plan = Survey.includes(job: :well).where(:plan => true).where("wells.id = ?", @survey.job.well_id).first

        @survey_point = SurveyPoint.new(params[:survey_point])
        @survey_point.survey = @survey
        @survey_point.company = @survey.company
        @survey_point.user = current_user
        @survey_point.user_name = current_user.name
        if !depth.blank?
            @survey_point.measured_depth = depth.to_s.gsub(/,/, '').to_f.convert_default(:ft, company_unit)
        end

        if params[:tie_in].present? && params[:tie_in] == "true"
            Survey.transaction do
                if !params[:gyro_company].blank? &&
                        !params[:gyro_date].blank? &&
                        !params[:mfs].blank? &&
                        !params[:mda].blank?

                    @survey.gyro_company = params[:gyro_company]
                    @survey.gyro_date = Time.strptime("#{params[:gyro_date]}", '%m/%d/%Y').in_time_zone(Time.zone)
                    @survey.magnetic_field_strength = params[:mfs].to_f
                    @survey.magnetic_dip_angle = params[:mda].to_f
                    @survey.gravity_total = 1.0
                    @survey.total_correction = params[:total_correction].to_f
                    @survey.north_type = params[:north_type].to_i
                    @survey.save

                    @survey_point.course_length = 0.0
                    @survey_point.measured_depth = params[:md].to_f.convert_default(:ft, company_unit)
                    @survey_point.inclination = params[:i].to_f
                    @survey_point.azimuth = params[:a].to_f
                    @survey_point.true_vertical_depth = params[:tvd].to_f.convert_default(:ft, company_unit)
                    @survey_point.vertical_section = params[:vs].to_f.convert_default(:ft, company_unit)
                    @survey_point.dog_leg_severity = params[:dls].to_f
                    @survey_point.north_south = params[:ns].to_f
                    @survey_point.east_west = params[:ew].to_f
                    @survey_point.tie_on = true
                    @survey_point.comment = "Tie In"
                    @survey_point.save
                else
                    @survey_point.errors.add(:survey, "Tie-In fields can't be empty")
                end
            end
        else
            if @survey_point.measured_depth.present? &&
                    @survey_point.measured_depth != 0 &&
                    @survey_point.inclination.present? &&
                    @survey_point.azimuth.present?

                @survey_point.tie_on = false
                last_survey = @survey.survey_points.last
                if last_survey.present? && last_survey.measured_depth == @survey_point.measured_depth
                    @survey_point.errors.add(:survey, "is duplicate of existing entry. That measured depth has already been taken.")
                else
                    @survey_point.save
                end
            else
                @survey_point.errors.add(:survey, "fields can't be empty. Or, depth can't be the same as last survey.")
            end
        end

    end

    def edit
        @survey_point = SurveyPoint.find_by_id(params[:id])
        not_found unless @survey_point.present?
    end

    def update
        @survey_point = SurveyPoint.find_by_id(params[:id])
        not_found unless @survey_point.present?
        if params[:survey_point][:measured_depth].present? &&
                (params[:survey_point][:measured_depth].to_f != 0 || @survey_point.tie_on?) &&
                params[:survey_point][:inclination].present? &&
                params[:survey_point][:azimuth].present?
            params[:survey_point][:measured_depth] = params[:survey_point][:measured_depth].to_f.convert_default(:ft, company_unit)
            params[:survey_point][:true_vertical_depth] = params[:survey_point][:true_vertical_depth].to_f.convert_default(:ft, company_unit)
            params[:survey_point][:vertical_section] = params[:survey_point][:vertical_section].to_f.convert_default(:ft, company_unit)
            @survey_point.update_attributes(params[:survey_point])
        else
            @survey_point.errors.add(:survey, "fields can't be empty")
        end

        if @survey_point.tie_on? &&
                @survey_point.magnetic_field_strength.present? &&
                @survey_point.magnetic_dip_angle.present?
            @survey_point.survey.magnetic_field_strength = @survey_point.magnetic_field_strength
            @survey_point.survey.magnetic_dip_angle = @survey_point.magnetic_dip_angle
            @survey_point.survey.total_correction = params[:total_correction].to_f
            @survey_point.survey.north_type =  params[:north_type].to_i
            @survey_point.survey.save
        end
    end

    def destroy
        @survey_point = SurveyPoint.find_by_id(params[:id])
        not_found unless @survey_point.present?

        if @survey_point.tie_on? && @survey_point.survey.survey_points.count > 1
            @survey_point.errors.add(:tie_on, "can't be deleted with other survey points")
        else
            @survey_point.destroy
        end
    end
end
