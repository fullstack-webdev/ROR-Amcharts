# encoding: UTF-8

class DynamicField < ActiveRecord::Base
    attr_accessible :name,
                    :value_type,
                    :default_value_type,
                    :template,
                    :optional,
                    :priority,
                    :predefined,
                    :ordering,
                    :values

    acts_as_xlsx

    acts_as_tenant(:company)

    after_commit :flush_cache

    validates_presence_of :name
    #validates_inclusion_of :value_type_conversion , :in => %w(to_s to_i to_f to_b)
    validates :company, presence: true

    #validate :value_or_attachment

    #before_save :value_or_attachment
    belongs_to :dynamic_field_template, class_name: "DynamicField"
    belongs_to :job
    belongs_to :company

    STRING = 1
    VALUES = 2

    LENGTH = 10
    LENGTH_FT = 11
    LENGTH_IN = 12
    LENGTH_M = 13
    LENGTH_CM = 14
    LENGTH_MM = 15

    TEMPERATURE = 30
    TEMPERATURE_F = 31
    TEMPERATURE_C = 32

    PRESSURE = 40
    PRESSURE_PSI = 41
    PRESSURE_MPA = 42
    PRESSURE_PAS = 43
    PRESSURE_BAR = 44

    RATE = 50
    RATE_BBLS = 51
    RATE_M3 = 52

    VOLUME = 60
    VOLUME_BBLS = 61
    VOLUME_M3 = 62

    AREA = 70
    AREA_IN2 = 71
    AREA_CM2 = 72

    WEIGHT = 80
    WEIGHT_LBS = 81
    WEIGHT_KG = 82
    WEIGHT_PPG = 83
    WEIGHT_SG = 84
    WEIGHT_PPF = 85
    WEIGHT_KGM = 86

    WEIGHT_GRADIENT_PSIF = 90
    WEIGHT_GRADIENT_PSIM = 91
    WEIGHT_GRADIENT_SGF = 92
    WEIGHT_GRADIENT_SGM = 93

    ANGLE = 100
    ANGLE_100FT = 101

    VISCOSITY_PAS = 110
    VISCOSITY_KGSM = 111
    VISCOSITY_CP = 112


    def value
        storage_value_type = get_storage_value_type(read_attribute(:value_type))
        convert(read_attribute(:value), storage_value_type, read_attribute(:value_type))
    end

    def value=(value)
        storage_value_type = get_storage_value_type(read_attribute(:value_type))
        write_attribute(:value, convert(value, read_attribute(:value_type), storage_value_type))
    end

    def set_temporary_value(value)
        write_attribute(:value, value)
    end

    def value_type
        read_attribute(:value_type)
    end

    def value_type=(value_type)
        storage_value_type = get_storage_value_type(value_type.to_i)

        current_value = self.value
        write_attribute(:value_type, value_type.to_i)

        # Change value in DB if unit changed to non-default
        if storage_value_type != value_type
            write_attribute(:value, convert(current_value, value_type.to_i, storage_value_type))
        elsif write_attribute(:value, current_value)
        end
    end

    def   convert(value, value_type, new_value_type)

        if value.nil?
            return value
        end

        value_type = value_type.to_i
        new_value_type = new_value_type.to_i

        if value_type == new_value_type || value_type == STRING || value_type == VALUES
            return value
        end

        value = value.to_f

        case value_type
            when LENGTH_FT
                case new_value_type
                    when LENGTH_IN
                        value * 12
                    when LENGTH_M
                        value * 0.3048
                    when LENGTH_CM
                        value * 30.48
                end
            when LENGTH_IN
                case new_value_type
                    when LENGTH_FT
                        value / 12
                    when LENGTH_M
                        value * 0.0254
                    when LENGTH_CM
                        value * 2.54
                end
            when LENGTH_M
                case new_value_type
                    when LENGTH_FT
                        value * 3.28084
                    when LENGTH_IN
                        value * 39.3701
                    when LENGTH_CM
                        value * 100
                end
            when LENGTH_CM
                case new_value_type
                    when LENGTH_FT
                        value * 0.0328084
                    when LENGTH_IN
                        value * 0.393701
                    when LENGTH_M
                        value * 0.01
                end
            when TEMPERATURE_F
                case new_value_type
                    when TEMPERATURE_C
                        (value - 32) / 1.8
                end
            when TEMPERATURE_C
                case new_value_type
                    when TEMPERATURE_F
                        (value * 1.8) + 32
                end
            when PRESSURE_PSI
                case new_value_type
                    when PRESSURE_MPA
                        value * 0.00689475728
                    when PRESSURE_PAS
                        value * 6894.75729
                    when PRESSURE_BAR
                        value * 0.0689475729
                end
            when PRESSURE_MPA
                case new_value_type
                    when PRESSURE_PSI
                        value * 145.0377
                    when PRESSURE_PAS
                        value * 1000000
                    when PRESSURE_BAR
                        value * 10
                end
            when PRESSURE_PAS
                case new_value_type
                    when PRESSURE_PSI
                        value * 0.000145037738
                    when PRESSURE_MPA
                        value * 0.000001
                    when PRESSURE_BAR
                        value * 0.00001
                end
            when PRESSURE_BAR
                case new_value_type
                    when PRESSURE_PSI
                        value / 0.06894475729
                    when PRESSURE_MPA
                        value / 10
                    when PRESSURE_PAS
                        value / 0.00001
                end
            when RATE_BBLS
                case new_value_type
                    when RATE_M3
                        value * 0.158987
                end
            when RATE_M3
                case new_value_type
                    when RATE_BBLS
                        value * 6.28981
                end
            when VOLUME_BBLS
                case new_value_type
                    when VOLUME_M3
                        value * 0.158987
                end
            when VOLUME_M3
                case new_value_type
                    when VOLUME_BBLS
                        value * 6.28981
                end
            when AREA_IN2
                case new_value_type
                    when AREA_CM2
                        value * 6.4516
                end
            when AREA_CM2
                case new_value_type
                    when AREA_IN2
                        value * 0.1550031
                end
            when WEIGHT_LBS
                case new_value_type
                    when WEIGHT_KG
                        value * 0.453592
                end
            when WEIGHT_KG
                case new_value_type
                    when WEIGHT_LBS
                        value * 2.20462
                end
            when WEIGHT_PPG
                case new_value_type
                    when WEIGHT_SG
                        value / 8.34
                end
            when WEIGHT_SG
                case new_value_type
                    when WEIGHT_PPG
                        value * 8.34
                end
            when WEIGHT_PPF
                case new_value_type
                    when WEIGHT_KGM
                        (value *0.4535) / 0.3548
                end
            when WEIGHT_KGM
                case new_value_type
                    when WEIGHT_PPF
                        (value / 0.4535) * 0.3048
                end
            when WEIGHT_GRADIENT_PSIF
                case new_value_type
                    when WEIGHT_GRADIENT_PSIM
                        value / 0.3048
                    when WEIGHT_GRADIENT_SGF
                        value / 8.34
                    when WEIGHT_GRADIENT_SGM
                        (value / 8.34) / 0.3048
                end
            when WEIGHT_GRADIENT_PSIM
                case new_value_type
                    when WEIGHT_GRADIENT_PSIF
                        value / 3.28084
                    when WEIGHT_GRADIENT_SGF
                        (value / 8.34) * 0.3048
                    when WEIGHT_GRADIENT_SGM
                        value / 8.34
                end
            when WEIGHT_GRADIENT_SGF
                case new_value_type
                    when WEIGHT_GRADIENT_PSIF
                        value * 8.34
                    when WEIGHT_GRADIENT_PSIM
                        (value * 8.34) / 0.3048
                    when WEIGHT_GRADIENT_SGM
                        value / 0.3048
                end
            when WEIGHT_GRADIENT_SGM
                case new_value_type
                    when WEIGHT_GRADIENT_PSIF
                        (value * 8.34) / 3.28084
                    when WEIGHT_GRADIENT_PSIM
                        value * 8.34
                    when WEIGHT_GRADIENT_SGF
                        value * 0.3048
                end
            when VISCOSITY_PAS
                case new_value_type
                    when VISCOSITY_KGSM
                        value
                    when VISCOSITY_CP
                        value
                end
            when VISCOSITY_KGSM
                case new_value_type
                    when VISCOSITY_PAS
                        value
                    when VISCOSITY_CP
                        value
                end
            when VISCOSITY_CP
                case new_value_type
                    when VISCOSITY_PAS
                        value
                    when VISCOSITY_KGSM
                        value
                end
        end
    end

    def value_type_unit
        get_value_type_unit(self.value_type)
    end

    def get_value_type_unit(value_type)

        return '' if value_type.nil?

        case value_type.to_i
            when STRING
                ""
            when VALUES
                ""
            when LENGTH_FT
                "ft"
            when LENGTH_IN
                "in"
            when LENGTH_M
                "m"
            when LENGTH_CM
                "cm"
            when LENGTH_MM
                "mm"
            when TEMPERATURE_F
                "f°"
            when TEMPERATURE_C
                "c°"
            when PRESSURE_PSI
                "psi"
            when PRESSURE_MPA
                "mpa"
            when PRESSURE_PAS
                "pas"
            when PRESSURE_BAR
                "bar"
            when RATE_BBLS
                "bbls/min"
            when RATE_M3
                "m^3/min"
            when VOLUME_BBLS
                "bbls"
            when VOLUME_M3
                "m^3"
            when AREA_IN2
                "in^2"
            when AREA_CM2
                "cm^2"
            when WEIGHT_LBS
                "lbs"
            when WEIGHT_KG
                "kg"
            when WEIGHT_PPG
                "ppg"
            when WEIGHT_SG
                "sg"
            when WEIGHT_PPF
                "lbs/ft"
            when WEIGHT_KGM
                "kg/m"
            when WEIGHT_GRADIENT_PSIF
                "psi/ft"
            when WEIGHT_GRADIENT_PSIM
                "psi/m"
            when WEIGHT_GRADIENT_SGF
                "sg/ft"
            when WEIGHT_GRADIENT_SGM
                "sg/m"
            when ANGLE
                "°"
            when ANGLE_100FT
                "°/100ft"
            when VISCOSITY_PAS
                "Pas/s"
            when VISCOSITY_KGSM
                "KG/s*m"
            when VISCOSITY_CP
                "cP"
        end
    end

    def value_type_unit_full
        get_value_type_unit_full(self.value_type)
    end

    def get_value_type_unit_full(value_type)

        case value_type.to_i
            when STRING
                ""
            when VALUES
                ""
            when LENGTH_FT
                "Feet"
            when LENGTH_IN
                "Inches"
            when LENGTH_M
                "Meters"
            when LENGTH_CM
                "Centimeters"
            when LENGTH_MM
                "Millimeters"
            when TEMPERATURE_F
                "Fahrenheit"
            when TEMPERATURE_C
                "Celsius"
            when PRESSURE_PSI
                "PSI"
            when PRESSURE_MPA
                "MegaPascals"
            when PRESSURE_PAS
                "Pascals"
            when PRESSURE_BAR
                "Bar"
            when RATE_BBLS
                "Barrels per Minute"
            when RATE_M3
                "Meters Cubed per Minute"
            when VOLUME_BBLS
                "Barrels"
            when VOLUME_M3
                "Meters Cubed"
            when AREA_IN2
                "Inches Squared"
            when AREA_CM2
                "Centimeters Squared"
            when WEIGHT_LBS
                "Pounds"
            when WEIGHT_KG
                "Kilograms"
            when WEIGHT_PPG
                "Pounds per Gallon"
            when WEIGHT_SG
                "Specific Gravity"
            when WEIGHT_PPF
                "Pounds per Foot"
            when WEIGHT_KGM
                "Kilograms per Meter"
            when WEIGHT_GRADIENT_PSIF
                "PSI per Foot"
            when WEIGHT_GRADIENT_PSIM
                "PSI per Meter"
            when WEIGHT_GRADIENT_SGF
                "Specific Gravity per Foot"
            when WEIGHT_GRADIENT_SGM
                "Specific Gravity per Meter"
            when ANGLE
                "Degrees"
            when ANGLE_100FT
                "Degrees per 100 Feet"
            when VISCOSITY_PAS
                "Pascal per Second"
            when VISCOSITY_KGSM
                "Kilogram per Second Meter"
            when VISCOSITY_CP
                "centi-Poise"
        end
    end

    def self.from_company(company)
        where("company_id = :company_id", company_id: company.id).order("name ASC")
    end

    def units
        units = Array.new

        units << ["Text", STRING]
        units << ["Preset Value Selection (separate by comma)", VALUES]
        units << ["Length | Feet", LENGTH_FT]
        units << ["Length | Inches", LENGTH_IN]
        units << ["Length | Meters", LENGTH_M]
        units << ["Length | Centimeters", LENGTH_CM]
        units << ["Temperature | Fahrenheit", TEMPERATURE_F]
        units << ["Temperature | Celsius", TEMPERATURE_C]
        units << ["Pressure | PSI", PRESSURE_PSI]
        units << ["Pressure | MegaPascals", PRESSURE_MPA]
        units << ["Pressure | Pascals", PRESSURE_PAS]
        units << ["Pressure | Bar", PRESSURE_BAR]
        units << ["Rate | Barrels per Minute", RATE_BBLS]
        units << ["Rate | Meters Cubed per Minute", RATE_M3]
        units << ["Volume | Barrels", VOLUME_BBLS]
        units << ["Volume | Meters Cubed", VOLUME_M3]
        units << ["Volume | Meters Cubed", VOLUME_M3]
        units << ["Area | Inches Squared", AREA_IN2]
        units << ["Area | Centimeters Squared", AREA_CM2]
        units << ["Weight | Pounds", WEIGHT_LBS]
        units << ["Weight | Kilogram", WEIGHT_KG]
        units << ["Weight | Pounds per Gallon", WEIGHT_PPG]
        units << ["Weight | Specific Gravity", WEIGHT_SG]
        units << ["Weight - Casing | Pounds per Foot", WEIGHT_PPF]
        units << ["Weight - Casing | Kilograms per Meter", WEIGHT_KGM]
        units << ["Weight - Gradient | PSI per Foot", WEIGHT_GRADIENT_PSIF]
        units << ["Weight - Gradient | PSI per Meter", WEIGHT_GRADIENT_PSIM]
        units << ["Weight - Gradient | Specific Gravity per Foot", WEIGHT_GRADIENT_SGF]
        units << ["Weight - Gradient | Specific Gravity per Meter", WEIGHT_GRADIENT_SGM]
        units << ["Angle", ANGLE]
        units << ["Angle - Degrees per 100 Feet", ANGLE_100FT]
        units << ["Viscosity | Pascal per Second", VISCOSITY_PAS]
        units << ["Viscosity | Kilogram per Second Meter", VISCOSITY_KGSM]
        units << ["Viscosity | centi-Poise", VISCOSITY_CP]

        units
    end

    def unit_options
        get_unit_options(!self.dynamic_field_template.nil? ? self.dynamic_field_template.value_type : self.value_type)
    end

    def unit_options2
        get_unit_options(self.value_type)
    end

    def get_unit_options(value_type)
        units = Array.new

        case value_type.to_i
            when LENGTH_FT, LENGTH_M
                units << ["ft", LENGTH_FT]
                units << ["m", LENGTH_M]
            when LENGTH_IN, LENGTH_CM
                units << ["in", LENGTH_IN]
                units << ["cm", LENGTH_CM]
            when TEMPERATURE_F, TEMPERATURE_C
                units << ["f°", TEMPERATURE_F]
                units << ["c°", TEMPERATURE_C]
            when PRESSURE_PSI, PRESSURE_MPA, PRESSURE_PAS, PRESSURE_BAR
                units << ["psi", PRESSURE_PSI]
                units << ["mpa", PRESSURE_MPA]
                units << ["pas", PRESSURE_PAS]
                units << ["bar", PRESSURE_BAR]
            when RATE_BBLS, RATE_M3
                units << ["bbls/min", RATE_BBLS]
                units << ["m^3/min", RATE_M3]
            when VOLUME_BBLS, VOLUME_M3
                units << ["bbls", VOLUME_BBLS]
                units << ["m^3", VOLUME_M3]
            when AREA_IN2, AREA_CM2
                units << ["in^2", AREA_IN2]
                units << ["cm^2", AREA_CM2]
            when WEIGHT_LBS, WEIGHT_KG
                units << ["lbs", WEIGHT_LBS]
                units << ["kg", WEIGHT_KG]
            when WEIGHT_PPG, WEIGHT_SG
                units << ["ppg", WEIGHT_PPG]
                units << ["sg", WEIGHT_SG]
            when WEIGHT_PPF, WEIGHT_KGM
                units << ["lb/ft", WEIGHT_PPF]
                units << ["kg/m", WEIGHT_KGM]
            when WEIGHT_GRADIENT_PSIF, WEIGHT_GRADIENT_PSIM, WEIGHT_GRADIENT_SGF, WEIGHT_GRADIENT_SGM
                units << ["psi/ft", WEIGHT_GRADIENT_PSIF]
                units << ["psi/m", WEIGHT_GRADIENT_PSIM]
                units << ["sg/ft", WEIGHT_GRADIENT_SGF]
                units << ["sg/m", WEIGHT_GRADIENT_SGM]
            when ANGLE
                units << ["°", ANGLE]
            when ANGLE_100FT
                units << ["°", ANGLE_100FT]
            when VISCOSITY_PAS, VISCOSITY_KGSM, VISCOSITY_CP
                units << ["cP", VISCOSITY_CP]
                units << ["Pas/s", VISCOSITY_PAS]
                units << ["Kg/s*m", VISCOSITY_KGSM]
        end

        units
    end

    def get_unit_options_full(value_type)
        units = Array.new

        case value_type.to_i
            when LENGTH_FT, LENGTH_M
                units << ["Feet", LENGTH_FT]
                units << ["Meters", LENGTH_M]
            when LENGTH_IN, LENGTH_CM
                units << ["Inches", LENGTH_IN]
                units << ["Centimeters", LENGTH_CM]
            when TEMPERATURE_F, TEMPERATURE_C
                units << ["Fahrenheit", TEMPERATURE_F]
                units << ["Celsius", TEMPERATURE_C]
            when PRESSURE_PSI, PRESSURE_MPA, PRESSURE_PAS, PRESSURE_BAR
                units << ["PSI", PRESSURE_PSI]
                units << ["MegaPascals", PRESSURE_MPA]
                units << ["Pascals", PRESSURE_PAS]
                units << ["Bar", PRESSURE_BAR]
            when RATE_BBLS, RATE_M3
                units << ["Barrels per Minute", RATE_BBLS]
                units << ["Meters Cubed per Minute", RATE_M3]
            when VOLUME_BBLS, VOLUME_M3
                units << ["Barrels", VOLUME_BBLS]
                units << ["Meters Cubed", VOLUME_M3]
            when AREA_IN2, AREA_CM2
                units << ["Inches Squared", AREA_IN2]
                units << ["Centimeters Squared", AREA_CM2]
            when WEIGHT_LBS, WEIGHT_KG
                units << ["Pounds", WEIGHT_LBS]
                units << ["Kilograms", WEIGHT_KG]
            when WEIGHT_PPG, WEIGHT_SG
                units << ["Pounds per Gallon", WEIGHT_PPG]
                units << ["Specific Gravity", WEIGHT_SG]
            when WEIGHT_PPF, WEIGHT_KGM
                units << ["Pounds per Foot", WEIGHT_PPF]
                units << ["Kilograms per Meter", WEIGHT_KGM]
            when WEIGHT_GRADIENT_PSIF, WEIGHT_GRADIENT_PSIM, WEIGHT_GRADIENT_SGF, WEIGHT_GRADIENT_SGM
                units << ["PSI per Foot", WEIGHT_GRADIENT_PSIF]
                units << ["PSI per Meter", WEIGHT_GRADIENT_PSIM]
                units << ["Specific Gravity per Foot", WEIGHT_GRADIENT_SGF]
                units << ["Specific Gravity per Meter", WEIGHT_GRADIENT_SGM]
            when ANGLE
                units << ["Degrees", ANGLE]
            when ANGLE_100FT
                units << ["Degrees per 100 Feet", ANGLE_100FT]
            when VISCOSITY_PAS, VISCOSITY_KGSM, VISCOSITY_CP
                units << ["centi-Poise", VISCOSITY_CP]
                units << ["Pascal/Second", VISCOSITY_PAS]
                units << ["Kilogram per Second Meter", VISCOSITY_KGSM]
        end

        units
    end

    def get_storage_value_type(value_type)
        case value_type.to_i
            when STRING
                STRING
            when VALUES
                VALUES
            when LENGTH_FT, LENGTH_M
                LENGTH_FT
            when LENGTH_IN, LENGTH_CM
                LENGTH_IN
            when TEMPERATURE_F, TEMPERATURE_C
                TEMPERATURE_F
            when PRESSURE_PSI, PRESSURE_MPA, PRESSURE_PAS, PRESSURE_BAR
                PRESSURE_PSI
            when RATE_BBLS, RATE_M3
                RATE_BBLS
            when VOLUME_BBLS, VOLUME_M3
                VOLUME_BBLS
            when AREA_IN2, AREA_CM2
                AREA_IN2
            when WEIGHT_LBS, WEIGHT_KG
                WEIGHT_LBS
            when WEIGHT_PPG, WEIGHT_SG
                WEIGHT_PPG
            when WEIGHT_PPF, WEIGHT_KGM
                WEIGHT_PPF
            when WEIGHT_GRADIENT_PSIF, WEIGHT_GRADIENT_PSIM, WEIGHT_GRADIENT_SGF, WEIGHT_GRADIENT_SGM
                WEIGHT_GRADIENT_PSIF
            when ANGLE
                ANGLE
            when ANGLE_100FT
                ANGLE_100FT
            when VISCOSITY_PAS, VISCOSITY_KGSM, VISCOSITY_CP
                VISCOSITY_CP
        end
    end


    def get_user_conversion(user, parenthesis = false, output_always = false, full_unit = false)

        user_value_type = LENGTH

        if user.user_unit.nil?
            user_value_type = self.value_type
        else
            case self.value_type.to_i
                when LENGTH_FT, LENGTH_M
                    user_value_type = user.user_unit.length_outer || self.value_type
                when LENGTH_IN, LENGTH_CM
                    user_value_type = user.user_unit.length_inner || self.value_type
                when TEMPERATURE_F, TEMPERATURE_C
                    user_value_type = user.user_unit.temperature || self.value_type
                when PRESSURE_PSI, PRESSURE_MPA, PRESSURE_PAS, PRESSURE_BAR
                    user_value_type = user.user_unit.pressure || self.value_type
                when RATE_BBLS, RATE_M3
                    user_value_type = user.user_unit.rate || self.value_type
                when VOLUME_BBLS, VOLUME_M3
                    user_value_type = user.user_unit.volume || self.value_type
                when AREA_IN2, AREA_CM2
                    user_value_type = user.user_unit.area || self.value_type
                when WEIGHT_LBS, WEIGHT_KG
                    user_value_type = user.user_unit.weight || self.value_type
                when WEIGHT_PPF, WEIGHT_KGM
                    user_value_type = user.user_unit.weight_casing || self.value_type
                when WEIGHT_GRADIENT_PSIF, WEIGHT_GRADIENT_PSIM, WEIGHT_GRADIENT_SGF, WEIGHT_GRADIENT_SGM
                    user_value_type = user.user_unit.weight_gradient || self.value_type
                when ANGLE
                    user_value_type =  self.value_type
                when ANGLE_100FT
                    user_value_type =  self.value_type
                when VISCOSITY_PAS, VISCOSITY_KGSM, VISCOSITY_CP
                    user_value_type = user.user_unit.viscosity || self.value_type
            end
        end


        if (user_value_type != nil && user_value_type != self.value_type) || output_always
            value = self.value
            if (value.to_f != 0) || output_always

                unit = full_unit ? get_value_type_unit_full(user_value_type).to_s : get_value_type_unit(user_value_type).to_s

                if parenthesis
                    return "(" + convert(value, self.value_type, user_value_type).to_f.round(2).to_s + " " + unit + ")"
                else
                    return convert(value, self.value_type, user_value_type).to_f.round(2).to_s + " " + unit
                end
            end
        end

        ""
    end

    def flush_cache
        if self.job.present?
            self.job.flush_cache_status_percentage
        end
    end

    private

    def value_or_attachment
        if !template? && !value?
            errors[:base] << 'Must have value'
        end
    end

end
