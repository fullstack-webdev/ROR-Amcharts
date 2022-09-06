class SurveyPoint < ActiveRecord::Base
    attr_accessible :measured_depth,
                    :inclination,
                    :azimuth,
                    :course_length,
                    :tie_on,
                    :true_vertical_depth,
                    :east_west,
                    :north_south,
                    :vertical_section,
                    :dog_leg_severity,
                    :closure_distance,
                    :closure_angle,
                    :comment,
                    :user_name,
                    :magnetic_field_strength,
                    :magnetic_dip_angle,
                    :gravity_total

    belongs_to :company
    belongs_to :survey
    belongs_to :user


    def self.create survey, user, comment, measured_depth, inclination, azimuth
        survey_point = SurveyPoint.new
        survey_point.company = survey.company
        survey_point.user = user
        survey_point.user_name = user.name
        survey_point.survey = survey
        survey_point.comment = comment
        survey_point.tie_on = false
        survey_point.measured_depth = measured_depth
        survey_point.inclination = inclination
        survey_point.azimuth = azimuth
        survey_point.save
        survey_point
    end

    def valid_magnetic_field_strength?
        return true if self.magnetic_field_strength.blank?
        return self.magnetic_field_strength > (self.survey.magnetic_field_strength - 0.005) &&
                self.magnetic_field_strength < (self.survey.magnetic_field_strength + 0.005)
    end

    def valid_magnetic_dip_angle?
        return true if self.magnetic_dip_angle.blank?
        return self.magnetic_dip_angle > (self.survey.magnetic_dip_angle - 2) &&
                self.magnetic_dip_angle < (self.survey.magnetic_dip_angle + 2)
    end

    def valid_gravity_total?
        return true if self.gravity_total.blank?
        return self.gravity_total > (self.survey.gravity_total - 0.003) &&
                self.gravity_total < (self.survey.gravity_total + 0.003)
    end

end
