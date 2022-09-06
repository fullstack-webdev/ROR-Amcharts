class CompanyFeature < ActiveRecord::Base
    attr_accessible :enabled,
                    :feature

    validates :company, presence: true
    validates :feature, presence: true

    before_save :default_values

    def default_values
        self.enabled ||= true
    end

    acts_as_tenant(:company)

    belongs_to :company

    PERFORMANCE = 1
    GENERAL_ANALYSIS = 2
    LOST_TIME_ANALYSIS = 3

    WELLBORE_STABILITY = 10
    TORQUE_AND_DRAG = 11
    HOLE_CLEANING = 12
    KICKS = 13
    GAIN_LOSS = 14
    VIBRATION = 15
    MOTOR = 16
    DRILLING_OPTIMIZATION = 17
    RAW = 18
    DATA_FIX = 19

    def self.is_enabled features_array, feature_id
        if features_array != nil
            feature = features_array.select { |f| f.feature == feature_id }.first
            return feature != nil && feature.enabled
        else
            return false
        end
    end

    def self.possible_features
        [PERFORMANCE, GENERAL_ANALYSIS, LOST_TIME_ANALYSIS, WELLBORE_STABILITY, TORQUE_AND_DRAG,
         HOLE_CLEANING, KICKS, GAIN_LOSS, VIBRATION, MOTOR, DRILLING_OPTIMIZATION, RAW, DATA_FIX]
    end

    def self.is_free_tier feature
        if feature == PERFORMANCE || feature == GENERAL_ANALYSIS || feature == LOST_TIME_ANALYSIS || feature == RAW || feature == DATA_FIX
            return true
        end
        false
    end

    def self.feature_to_string feature
        case feature
            when PERFORMANCE
                return "Performance"
            when GENERAL_ANALYSIS
                return "General Analysis"
            when LOST_TIME_ANALYSIS
                return "Lost Time Analysis"
            when WELLBORE_STABILITY
                return "Wellbore Stability"
            when TORQUE_AND_DRAG
                return "Torque and Drag"
            when HOLE_CLEANING
                return "Hole Cleaning"
            when KICKS
                return "Kicks"
            when GAIN_LOSS
                return "Gain and Loss"
            when VIBRATION
                return "Vibration"
            when MOTOR
                return "Motor"
            when DRILLING_OPTIMIZATION
                return "Drilling Optimization"
            when RAW
                return "Raw"
            when DATA_FIX
                return "Data Fix"
            else
                return "-"
        end
    end

end
