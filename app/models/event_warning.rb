class EventWarning < ActiveRecord::Base
    attr_accessible :closed_at,
                    :opened_at,
                    :depth_from,
                    :depth_to,
                    :info

    belongs_to :company
    belongs_to :job
    belongs_to :event_warning_type, primary_key: 'warning_id'

    validates :company, presence: true
    validates :job, presence: true
    validates :event_warning_type, presence: true
    validates :depth_from, presence: true
    validates :opened_at, presence: true

    TRAY_NAMES = ['', 'rig_overview_stability']

    PER_PAGE = 10

    def level_name
        self.event_warning_type.severity_text
    end

    def family_name
        self.event_warning_type.category_label
    end

    def name
        self.event_warning_type.name
    end

    def severity
        return self.event_warning_type.present? ? self.event_warning_type.severity : ''
    end

    def duration(full_word=false)
        if self.closed_at.present?
            duration = self.closed_at.to_time.to_i - self.opened_at.to_time.to_i
            if duration < 60
                return duration.to_s + 's'
            elsif duration < 3600
                return (duration/60).round.to_s + (full_word ? ' minutes' : 'm')
            elsif duration < 3600*24
                return (duration/3600).round.to_s + (full_word ? ' hours' : 'h')
            else
                return (duration/(3600*24)).round.to_s + (full_word ? ' days' : 'd')
            end
        else
            return ''
        end
    end

    def activity_name
        # old code unlikely to use due to performance issue
        # result = WitsActivityList.where('job_id = ? AND start_time <= ? AND end_time >= ?', self.job_id, self.opened_at.utc, self.opened_at.utc).order('end_time DESC').select('activity_name').limit(1)
        # if result.empty?
        #     return ''
        # else
        #     return result[0].activity_name.to_s
        # end

        GlobalConstants::ACTIVITIES[activity_id]
    end

    def wits_start
        WitsRecord.table_name = "wits_records#{self.job_id}"
        record = WitsRecord.where("entry_at >= ? AND entry_at <= ?", self.opened_at.utc, self.opened_at.utc + 1.minute).order('entry_at DESC').limit(1).try(:first)
        return record
    end

    def wits_end
        WitsRecord.table_name = "wits_records#{self.job_id}"
        if self.closed_at.present?
            record = WitsRecord.where("entry_at >= ? AND entry_at <= ?", self.closed_at.utc, self.closed_at.utc + 1.minute).order('entry_at DESC').limit(1).try(:first)
        else
            record = WitsRecord.where("entry_at >= ?", self.closed_at.utc).order('entry_at DESC').limit(1).try(:first)
        end
        return record
    end

    def wits_range
        result = WitsRecord.find_by_sql("
            SELECT MIN(hole_depth) as start_depth, MAX(hole_depth) as end_depth,
                    AVG(rotary_rpm) as avg_rotary_rpm, MIN(rotary_rpm) as min_rotary_rpm, MAX(rotary_rpm) as max_rotary_rpm,
                    AVG(rotary_torque) as avg_rotary_torque, MIN(rotary_torque) as min_rotary_torque, MAX(rotary_torque) as max_rotary_torque,
                    AVG(weight_on_bit) as avg_weight_on_bit, MIN(weight_on_bit) as min_weight_on_bit, MAX(rotary_torque) as max_weight_on_bit,
                    AVG(mud_flow_in) as avg_mud_flow_in, MIN(mud_flow_in) as min_mud_flow_in, MAX(mud_flow_in) as max_mud_flow_in
            FROM wits_records#{self.job_id}
            WHERE (rotary_rpm > 0 OR weight_on_bit > 0 OR mud_flow_in > 0 OR weight_on_bit > 0) AND
                entry_at >= '#{self.opened_at.utc}' AND entry_at <= '#{self.closed_at != nil ? self.closed_at.utc : self.closed_at.utc + 10.hours}';")

        return result.first

    end

    # def depth_from
    #   result = WitsActivityList.where('job_id = ? AND start_time <= ? AND end_time >= ?', self.job_id, self.opened_at.utc, self.opened_at.utc).order('end_time DESC').select('bit_depth').limit(1)
    #   if result.empty?
    #     return 0
    #   else
    #     return result[0].bit_depth
    #   end
    # end
    #
    # def depth_to
    #   if self.closed_at.present?
    #     result = WitsActivityList.where('job_id = ? AND start_time <= ? AND end_time >= ?', self.job_id, self.closed_at.utc, self.closed_at.utc).order('end_time DESC').select('bit_depth').limit(1)
    #     if result.empty?
    #       return 0
    #     else
    #       return result[0].bit_depth
    #     end
    #   else
    #     return 0
    #   end
    # end

    def color
        return 'orange'
    end

    def rgb_color
        case self.severity
            when 'low'
                return '#ffc618'
            when 'moderate'
                return '#fc8100'
            when 'high'
                return '#fe0000'
        end
    end

    def tray_name
        case self.event_warning_type.category.to_i
            when CompanyFeature::PERFORMANCE
                ""
            when CompanyFeature::WELLBORE_STABILITY
                "rig_overview_stability"
            when CompanyFeature::TORQUE_AND_DRAG
                "rig_overview_tandd"
            when CompanyFeature::HOLE_CLEANING
                "rig_overview_cleaning"
            when CompanyFeature::DRILLING_OPTIMIZATION
                "rig_overview_whirl"
            when CompanyFeature::VIBRATION
                "rig_overview_bit"
            when CompanyFeature::MOTOR
                "rig_overview_motor"
            when CompanyFeature::GAIN_LOSS
                "rig_overview_losses"
            when CompanyFeature::KICKS
                "rig_overview_kicks"
            when CompanyFeature::KICKS
                "rig_overview_raw"
            else
                "rig_overview"
        end
    end

    def description
        self.event_warning_type.description
    end

    def resolution
        self.event_warning_type.resolution
    end

    def contact
        self.company.phone_number
    end

    def short_resolution
        resolution
    end

    def deletable_by(user)
        # (self.company == user.company && user.role_id >= 50) || user.admin == true
        user.admin == true
    end

    def self.max_updated_at_by_job(id)
        self.maximum(:updated_at, conditions: ['job_id = ?', id]).try(:utc).try(:to_s, :number)
    end
end
