class Survey < ActiveRecord::Base
    attr_accessible :name,
                    :plan,
                    :no_well_plan,
                    :north_type,
                    :vertical_section_azimuth,
                    :gyro_company,
                    :gyro_date,
                    :magnetic_field_strength,
                    :magnetic_dip_angle,
                    :gravity_total,
                    :total_correction,
                    :grid_type

    belongs_to :company
    belongs_to :job
    belongs_to :user

    has_many :survey_points, :dependent => :destroy, :order => "survey_points.measured_depth ASC"

    belongs_to :well_plan_for_survey, class_name: "Survey"

    TRUE = 1
    MAGNETIC = 2
    GRID = 3

    def calculated_points vertical_section_azimuth
        survey_points = self.survey_points.order("measured_depth ASC").to_a

        last_point = nil

        target_vs = vertical_section_azimuth

        survey_points.each do |point|
            point = Survey.calculate_point point, last_point, target_vs
            last_point = point
        end

        survey_points
    end

    def self.calculate_point point, last_point, target_vs

        if point.inclination.nil?
            point.inclination = 0.0
        end
        if point.azimuth.nil?
            point.azimuth = 0.0
        end

        if target_vs.nil?
            target_vs = 0.0
        end
        rc = 1.0
        rf = 1.0

        pi = Math::PI

        if point.tie_on
            if point.true_vertical_depth.nil?
                point.true_vertical_depth = 0.0
            end
            if point.vertical_section.nil?
                point.vertical_section = 0.0
            end
            if point.dog_leg_severity.nil?
                point.dog_leg_severity = 0.0
            end

            point.closure_distance = Math::sqrt((point.north_south * point.north_south) + (point.east_west * point.east_west))
            point.closure_angle = point.north_south == 0 ? Math::atan(point.east_west.abs / 0.00001) * (180/pi) : Math::atan(point.east_west.abs / point.north_south.abs) * (180/pi)


        elsif last_point == nil
            point.true_vertical_depth = 0.0
            point.north_south = 0.0
            point.east_west = 0.0
            point.vertical_section = 0.0
        else
            if point.inclination - last_point.inclination != 0 || point.azimuth - last_point.azimuth != 0
                beta = Math::cos((point.inclination - last_point.inclination) * (pi/180)) - (Math::sin(last_point.inclination*(pi/180)) * Math::sin(point.inclination*(pi/180)) * (1-Math::cos((point.azimuth - last_point.azimuth)*(pi/180))))
                beta = Math::acos(beta)
                rf = (2 / beta) * Math::tan(beta / 2)
                if rf.nan?
                    rf = 1.0
                end
                #rc = (point.measured_depth - last_point.measured_depth) * (Math::sin(point.inclination*(Math::PI/180)) - Math::sin(last_point.inclination*(Math::PI/180)) ) / ((point.inclination - last_point.inclination)*(Math::PI/180))
            end

            md_change = point.measured_depth - last_point.measured_depth
            ns_change = (md_change)/2 * ((Math::sin(last_point.inclination*(pi/180)) * Math::cos(last_point.azimuth*(pi/180))) + (Math::sin(point.inclination*(pi/180)) * Math::cos(point.azimuth*(pi/180)))) * rf
            ew_change = (md_change)/2 * ((Math::sin(last_point.inclination*(pi/180)) * Math::sin(last_point.azimuth*(pi/180))) + (Math::sin(point.inclination*(pi/180)) * Math::sin(point.azimuth*(pi/180)))) * rf
            v_change = (md_change)/2 * (Math::cos(last_point.inclination*(pi/180)) + Math::cos(point.inclination*(pi/180))) * rf

            point.course_length = md_change
            point.true_vertical_depth = last_point.true_vertical_depth + v_change
            point.north_south = last_point.north_south + ns_change
            point.east_west = last_point.east_west + ew_change

            point.dog_leg_severity = ((200/md_change) * (Math::acos(Math::sqrt(0.5*(1 + Math::cos(last_point.inclination * pi/180) * Math::cos(point.inclination * pi/180) + Math::sin(last_point.inclination * pi/180) * Math::sin(point.inclination * pi/180) * Math::cos((point.azimuth-last_point.azimuth) * pi/180))))*180/pi))
            dla = md_change / 100

            point.closure_distance = Math::sqrt((point.north_south * point.north_south) + (point.east_west * point.east_west))
            point.closure_angle = point.north_south == 0 ? Math::atan(point.east_west.abs / 0.00001) * (180/pi) : Math::atan(point.east_west.abs / point.north_south.abs) * (180/pi)

            cl_dir1 = 0.0
            cl_dir2 = 0.0

            if point.north_south > 0 && point.east_west > 0
                cl_dir1 = point.closure_angle
            elsif point.north_south < 0 && point.east_west > 0
                cl_dir1 = 180 - point.closure_angle
            elsif point.north_south < 0 && point.east_west < 0
                cl_dir1 = 180 + point.closure_angle
            elsif point.north_south > 0 && point.east_west < 0
                cl_dir1 = 360 - point.closure_angle
            end

            if point.north_south > 0 && point.east_west == 0
                cl_dir2 = 0
            elsif point.north_south == 0 && point.east_west > 0
                cl_dir2 = 90
            elsif point.north_south < 0 && point.east_west == 0
                cl_dir2 = 180
            elsif point.north_south == 0 && point.east_west < 0
                cl_dir2 = 270
            elsif point.north_south == 0 && point.east_west == 0
                cl_dir2 = 0
            end

            direction_difference = 0.0
            closure_direction = 0.0

            # Need to find when to execute else
            if true
                if target_vs > cl_dir1
                    direction_difference = target_vs - cl_dir1
                else
                    cl_dir1 > target_vs
                    direction_difference = cl_dir1 - target_vs
                end
                closure_direction = cl_dir1
            else
                if cl_dir2 > target_vs
                    direction_difference = cl_dir2 - target_vs
                elsif target_vs > cl_dir2
                    direction_difference = target_vs - cl_dir2
                end
                closure_direction = cl_dir2
            end

            point.vertical_section = point.closure_distance * Math::cos(direction_difference * (pi/180))
            if point.vertical_section == 0
                point.vertical_section = point.vertical_section.abs
            end

            build_rate = (100 / (point.measured_depth - last_point.measured_depth)) * (point.inclination - last_point.inclination)

            if last_point.azimuth > 270 && point.azimuth < 90
                walk_rate = (100 / (point.measured_depth - last_point.measured_depth)) * ((360 - last_point.azimuth) + point.azimuth)
            elsif last_point.azimuth < 90 && point.azimuth > 270
                walk_rate = (100 / (point.measured_depth - last_point.measured_depth)) * (point.azimuth - (360 + last_point.azimuth))
            else
                walk_rate = (100 / (point.measured_depth - last_point.measured_depth)) * (point.azimuth - last_point.azimuth)
            end

        end

        #cd = Math::sqrt((point.east_west * point.east_west) + (point.north_south * point.north_south))
        #ca = Math::atan(point.east_west / point.north_south)
        #point.vertical_section = cd # * Math::cos(ca - point.azimuth)

        point
    end

    def interpolate_point point, last_point, target_vs

    end

    def self.get_ranges entries
        return [[0, 0], [0, 0], [0, 0], [0, 0]] if entries.nil? || !entries.any?

        minimum_tvd = entries.first.true_vertical_depth || 0
        maximum_tvd = entries.first.true_vertical_depth || 0
        minimum_vs = entries.first.vertical_section || 0
        maximum_vs = entries.first.vertical_section || 0

        minimum_ns = entries.first.north_south || 0
        maximum_ns = entries.first.north_south || 0
        minimum_ew = entries.first.east_west || 0
        maximum_ew = entries.first.east_west || 0

        entries.each do |e|

            minimum_tvd = [minimum_tvd, e.true_vertical_depth || 0].min
            maximum_tvd = [maximum_tvd, e.true_vertical_depth || 0].max
            minimum_vs = [minimum_vs, e.vertical_section || 0].min
            maximum_vs = [maximum_vs, e.vertical_section || 0].max

            minimum_ns = [minimum_ns, e.north_south || 0].min
            maximum_ns = [maximum_ns, e.north_south || 0].max
            minimum_ew = [minimum_ew, e.east_west || 0].min
            maximum_ew = [maximum_ew, e.east_west || 0].max
        end

        [[minimum_tvd, maximum_tvd], [minimum_vs, maximum_vs], [minimum_ns, maximum_ns], [minimum_ew, maximum_ew]]
    end
end
