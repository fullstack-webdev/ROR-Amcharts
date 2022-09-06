class DrillingLog < ActiveRecord::Base
    attr_accessible :below_rotary,
                    :above_rotary,
                    :drilling_time,
                    :total_circulation_time,
                    :circulation_hours,
                    :ream_hours,
                    :rop,
                    :drilling_rop,
                    :rotary_footage_pct,
                    :rotary_hours_pct,
                    :rotate_footage,
                    :rotate_hours,
                    :rotate_rop,
                    :slide_footage_pct,
                    :slide_footage,
                    :slide_hours,
                    :slide_hours_pct,
                    :slide_rop,
                    :total_drilled,
                    :max_depth,
                    :td_depth,
                    :npt,
                    :total_time

    acts_as_tenant(:company)

    validates_presence_of :company_id
    validates_presence_of :job_id

    belongs_to :company
    belongs_to :job
    belongs_to :well

    has_many :drilling_log_entries, order: "drilling_log_entries.entry_at ASC"

    attr_accessor :start_depth
    attr_accessor :end_depth

    attr_accessor :ranges

    include DrillingLogsHelper

    def recalculate
        drilling_log = DrillingLog.calculate self.drilling_log_entries

        DrillingLog.transaction do
            self.slide_footage = drilling_log.slide_footage
            self.slide_hours = drilling_log.slide_hours
            self.rotate_footage = drilling_log.rotate_footage
            self.rotate_hours = drilling_log.rotate_hours
            self.ream_hours = drilling_log.ream_hours
            self.circulation_hours = drilling_log.circulation_hours
            self.rotary_hours_pct = drilling_log.rotary_hours_pct
            self.rotary_footage_pct = drilling_log.rotary_footage_pct
            self.rotate_rop = drilling_log.rotate_rop
            self.slide_hours_pct = drilling_log.slide_hours_pct
            self.slide_footage_pct = drilling_log.slide_footage_pct
            self.slide_rop = drilling_log.slide_rop
            self.above_rotary = drilling_log.above_rotary
            self.below_rotary = drilling_log.below_rotary
            self.total_drilled = drilling_log.total_drilled
            self.max_depth = drilling_log.max_depth
            self.rop = drilling_log.rop
            self.drilling_rop = drilling_log.drilling_rop
            self.drilling_time = drilling_log.drilling_time
            self.total_circulation_time = drilling_log.total_circulation_time
            self.npt = drilling_log.npt
            self.total_time = drilling_log.total_time

            if self.td_depth.blank? || self.td_depth == 0.0
                if self.job.present?
                    active_well_plan = Survey.includes(job: :well).where("wells.id = ?", self.job.well_id).where(:plan => true).order("surveys.updated_at ASC").first
                    if active_well_plan.present? && active_well_plan.survey_points.any?
                        self.td_depth = active_well_plan.survey_points.last.measured_depth
                    end
                end
            end

            self.save

            self.drilling_log_entries.each do |dl|
                if dl.changed?
                    dl.save
                end
            end
        end
    end

    def self.calculate drilling_log_entries
        drilling_log = DrillingLog.new
        entries = drilling_log_entries.to_a

        if entries.any?
            last_entry = entries.first
            last_time = entries.first.entry_at
            below = 0.0
            above = 0.0
            time = 0.0
            length_change = 0.0
            total_drill_time = 0.0
            total_drill_length = 0.0
            drilling_log.slide_footage = 0.0
            drilling_log.slide_hours = 0.0
            drilling_log.rotate_footage = 0.0
            drilling_log.rotate_hours = 0.0
            drilling_log.ream_hours = 0.0
            drilling_log.circulation_hours = 0.0
            drilling_log.max_depth = 0.0
            drilling_log.npt = 0.0
            drilling_log.total_time = 0.0

            drilling_log.ranges = {}

            entries.each do |entry|

                drilling_log.start_depth = drilling_log.start_depth.nil? ? entry.depth : [drilling_log.start_depth, entry.depth].min
                drilling_log.end_depth = drilling_log.end_depth.nil? ? entry.depth : [drilling_log.end_depth, entry.depth].max
                drilling_log.max_depth = drilling_log.max_depth.nil? ? entry.depth : [drilling_log.max_depth, entry.depth].max

                DrillingLogEntry.attribute_names.each do |attribute_name|
                    if attribute_name != "id" && attribute_name != "company_id" && attribute_name != "document_id" && attribute_name != "job_id" && attribute_name != "well_id" && attribute_name != "user_id" && attribute_name != "user_name" && attribute_name != "entry_at" && attribute_name != "created_at" && attribute_name != "updated_at" && attribute_name != "activity_code" && attribute_name != "depth" && attribute_name != "comment" && attribute_name != "bha_id" && attribute_name != "usage_hours" && attribute_name != "drilling_log_id" && attribute_name != "hours" && attribute_name != "rop" && attribute_name != "course_length"

                        if entry[attribute_name].present?
                            if drilling_log.ranges.has_key? (attribute_name + '_min')
                                drilling_log.ranges[attribute_name + '_min'] = [entry[attribute_name], drilling_log.ranges[attribute_name + '_min']].min
                                drilling_log.ranges[attribute_name + '_max'] = [entry[attribute_name], drilling_log.ranges[attribute_name + '_max']].max
                            else
                                drilling_log.ranges[attribute_name + '_min'] = entry[attribute_name]
                                drilling_log.ranges[attribute_name + '_max'] = entry[attribute_name]
                            end
                        end
                    end
                end

                length_change = entry.depth - last_entry.depth
                length_change = [length_change, 0.0].max
                time = [((entry.entry_at - last_time) / 60 / 60).to_f, 0.0].max

                if entry.activity_code != DrillingLogEntry::STANDBY_OUTHOLE
                    if entry.activity_code != DrillingLogEntry::DRILLING &&
                            entry.activity_code != DrillingLogEntry::SLIDING
                        drilling_log.npt += time
                    end
                    drilling_log.total_time += time
                end

                entry.course_length = length_change
                entry.hours = time

                if entry.activity_code >= 1 && entry.activity_code < 100
                    below += time
                else
                    above += time
                end

                if entry.activity_code == DrillingLogEntry::SLIDING || entry.activity_code == DrillingLogEntry::DRILLING
                    total_drill_length += length_change
                end

                if entry.activity_code == DrillingLogEntry::SLIDING
                    total_drill_time += time
                    drilling_log.slide_footage += length_change
                    drilling_log.slide_hours += time
                elsif entry.activity_code == DrillingLogEntry::DRILLING
                    total_drill_time += time
                    drilling_log.rotate_footage += length_change
                    drilling_log.rotate_hours += time
                elsif entry.activity_code == DrillingLogEntry::REAMING
                    drilling_log.ream_hours += time
                elsif entry.activity_code == DrillingLogEntry::CIRCULATING
                    drilling_log.circulation_hours += time
                elsif entry.activity_code == DrillingLogEntry::TIH_CIRCULATING
                    drilling_log.circulation_hours += time
                elsif entry.activity_code == DrillingLogEntry::CONNECTION_SURVEY
                    #total_drill_time += time
                elsif entry.activity_code == DrillingLogEntry::CONNECTION
                    #total_drill_time += time
                end

                last_time = entry.entry_at
                last_entry = entry

                if length_change > 0 && time > 0
                    entry.rop = length_change / time
                end
            end

            drilling_log.rotary_hours_pct = total_drill_time > 0 ? drilling_log.rotate_hours / total_drill_time : 0.0
            drilling_log.rotary_footage_pct = total_drill_length > 0 ? drilling_log.rotate_footage / total_drill_length : 0.0
            drilling_log.rotate_rop = drilling_log.rotate_hours > 0 ? drilling_log.rotate_footage / drilling_log.rotate_hours : 0.0
            drilling_log.slide_hours_pct = total_drill_time > 0 ? drilling_log.slide_hours / total_drill_time : 0.0
            drilling_log.slide_footage_pct = total_drill_length > 0 ? drilling_log.slide_footage / total_drill_length : 0.0
            drilling_log.slide_rop = drilling_log.slide_hours > 0 ? drilling_log.slide_footage / drilling_log.slide_hours : 0.0

            drilling_log.below_rotary = below
            drilling_log.above_rotary = above
            drilling_log.drilling_time = total_drill_time
            drilling_log.total_circulation_time = total_drill_time + drilling_log.circulation_hours
            drilling_log.total_drilled = total_drill_length
            rop_divisor = below + above
            drilling_log.rop = rop_divisor > 0 ? total_drill_length / rop_divisor : 0.0
            drilling_log.drilling_rop = total_drill_time > 0 ? total_drill_length / total_drill_time : 0.0
        end

        drilling_log.drilling_log_entries = entries
        drilling_log
    end

    def get_times(entries = self.drilling_log_entries.to_a)
        hash = {}

        if entries.any?
            last_entry = entries.first
            entries.each do |entry|
                time = ((entry.entry_at - last_entry.entry_at) / 60 / 60).to_f
                if hash.has_key?(entry.activity_code)
                    sub_hash = hash[entry.activity_code]
                    sub_hash[:time] += time
                    sub_hash[:entries] += 1
                else
                    hash.merge!(entry.activity_code => {time: time, activity_code: entry.activity_code, activity_code_string: DrillingLogEntry.activity_code_string(entry.activity_code), entries: 1})
                end

                last_entry = entry
            end
        end

        hash
    end


    def get_times2(entries = self.drilling_log_entries.to_a)
        hours = []

        current_hour = {hour: 0}
        current_hour_index = 0
        total_hour_time = 0
        if entries.any?
            last_entry = entries.first
            entries.each do |entry|
                time = ((entry.entry_at - last_entry.entry_at) / 60 / 60).to_f

                usage_time = 0
                overage = total_hour_time + time > 1
                if overage
                    usage_time = 1 - total_hour_time
                else
                    usage_time = time
                end

                puts usage_time

                if current_hour.has_key?(entry.activity_code)
                    current_hour[entry.activity_code] = (current_hour[entry.activity_code] + usage_time).round(2)
                else
                    current_hour.merge!(entry.activity_code => usage_time.round(2))
                end

                total_hour_time += usage_time

                while total_hour_time == 1 do
                    hours << current_hour
                    current_hour_index += 1
                    current_hour = {hour: current_hour_index}
                    total_hour_time = 0


                    if overage
                        time = time - usage_time
                        overage = total_hour_time + time > 1
                        if overage
                            usage_time = 1 - total_hour_time
                        else
                            usage_time = time
                        end

                        if current_hour.has_key?(entry.activity_code)
                            current_hour[entry.activity_code] = (current_hour[entry.activity_code] + usage_time).round(2)
                        else
                            current_hour.merge!(entry.activity_code => usage_time.round(2))
                        end

                        total_hour_time += usage_time
                    end
                end

                last_entry = entry
            end
        end

        hours
    end

    def get_connection_times(entries = self.drilling_log_entries.to_a)
        connections = []

        connections << { :time => entries.first.entry_at.beginning_of_day, :duration => 0 }

        total_hour_time = 0

        if entries.any?
            last_entry = entries.first
            entries.each do |entry|
                time = ((entry.entry_at - last_entry.entry_at) / 60 / 60).to_f

                if entry.activity_code == DrillingLogEntry::CONNECTION || entry.activity_code == DrillingLogEntry::CONNECTION_SURVEY
                    connections << { :time => entry.entry_at, :duration => (time * 60).round(1) }
                end

                total_hour_time += time

                if total_hour_time > 24
                    break
                end

                last_entry = entry
            end
        end

        connections
    end

    def get_runs(entries = self.drilling_log_entries.to_a)
        runs = []

        if entries.any?
            current_run = []
            pooh = false
            last_bha = nil

            entries.each do |entry|
                if entry.activity_code == DrillingLogEntry::POOH || entry.activity_code == DrillingLogEntry::LD_DP
                    pooh = true
                    last_bha = entry.bha
                end

                if pooh &&
                        (entry.bha != last_bha ||
                                entry.activity_code == DrillingLogEntry::CHANGE_BHA ||
                                entry.activity_code == DrillingLogEntry::TIH)
                    pooh = false
                    runs << current_run
                    current_run = []
                end

                if entry.activity_code >= 1 && entry.activity_code < 100
                    current_run << entry
                end

            end

            if current_run.any?
                runs << current_run
            end
        end

        runs
    end

    def get_surrounding_entries(date, window, entries = self.drilling_log_entries.to_a)
        surrounding_entries = []
        previous = nil
        closest = nil
        past = nil
        run_number = 1
        pooh = false
        last_bha = nil

        if entries.any?
            entries.each do |entry|
                if entry.activity_code == DrillingLogEntry::POOH || entry.activity_code == DrillingLogEntry::LD_DP
                    pooh = true
                    last_bha = entry.bha
                end

                if pooh &&
                        (entry.bha != last_bha ||
                                entry.activity_code == DrillingLogEntry::CHANGE_BHA ||
                                entry.activity_code == DrillingLogEntry::TIH)
                    pooh = false
                    run_number += 1
                end

                entry.run_number = run_number

                if window.nil? || (entry.entry_at >= (date - window) && entry.entry_at <= (date + window))
                    if !window.nil?
                        surrounding_entries << entry
                    end
                    if entry.entry_at < date
                        previous = entry
                    end
                    # Run after closest
                    if past.nil? && closest.present?
                        past = entry
                        if !window.nil?
                            return [surrounding_entries, [previous, closest, past]]
                        end
                    end
                    if closest.nil? && entry.entry_at >= date
                        closest = entry
                    end
                end
            end
        end

        if window.nil?
            runs = get_runs(entries)
            [runs[closest.present? ? (closest.run_number - 1) : 0], [previous, closest, past]]
        else
            [surrounding_entries, [previous, closest, past]]
        end
    end

    def start_on_job_phase
        if self.job.present?
            if self.job.status == Job::PRE_JOB
                self.job.begin_on_job
            end
        end
    end


    def create_report report_name, type, report_id
        report_exists = false
        @report_name = report_name
        @drilling_log = self

        case @report_name
            when "drilling_report"
                report_exists = true
            when "bha_report"
                report_exists = true
            when "run_report"
                report_exists = true
            when "daily_activity"
                report_exists = true
            when "survey"
                report_exists = true
            when "railroad"
                report_exists = true
            when "railroad_certification"
                report_exists = true
            when "incident_report"
                report_exists = true
        end

        if report_exists

            report = ODFReport::Report.new(Rails.root.join("app/assets/templates/#{@report_name}.odt")) do |r|
                case @report_name
                    when "drilling_report"
                        type = type.to_i
                        entries = @drilling_log.drilling_log_entries.includes(:bha).to_a
                        dates = entries.group_by { |item| item.entry_at.to_date }
                        dates.each_with_index do |d, index|
                            if type == index + 1
                                entries = d[1]
                            end
                        end

                        fill_drilling_report @drilling_log.job, entries, r, entries.any? ? entries.first.entry_at : Time.zone.now, entries.any? ? entries.last.entry_at : Time.zone.now
                    when "run_report"
                        index = type.to_i
                        if index > 0
                            runs = @drilling_log.get_runs
                            entries = runs[index - 1]
                        else
                            entries = @drilling_log.drilling_log_entries
                        end

                        fill_run_report @drilling_log.job, entries, r, entries.any? ? entries.first.entry_at : Time.zone.now, entries.any? ? entries.last.entry_at : Time.zone.now, index
                    when "bha_report"
                        bha_id = type.to_i
                        if bha_id > 0
                            bha = Bha.find_by_id(bha_id)
                            entries = @drilling_log.drilling_log_entries.where("drilling_log_entries.bha_id = ?", bha.id).to_a
                        else
                            entries = @drilling_log.drilling_log_entries
                            if entries.any?
                                bha = entries.last.bha
                            end
                        end
                        if bha.nil?
                            bha = Bha.new
                        end

                        fill_bha_report @drilling_log.job, entries, r, entries.any? ? entries.first.entry_at : Time.zone.now, entries.any? ? entries.last.entry_at : Time.zone.now, bha, 1
                    when "daily_activity"
                        type = type.to_i
                        entries = @drilling_log.drilling_log_entries.includes(:bha).to_a
                        dates = entries.group_by { |item| item.entry_at.to_date }
                        dates.each_with_index do |d, index|
                            if type == index + 1
                                entries = d[1]
                            end
                        end

                        fill_log @drilling_log.job, entries, r, entries.any? ? entries.first.entry_at : Time.zone.now, entries.any? ? entries.last.entry_at : Time.zone.now
                    when "survey"
                        @active_well_plan = Survey.includes(job: :well).where(:plan => true).where("wells.id = ?", @drilling_log.job.well_id).first
                        @survey = Survey.includes(job: :well).where(:plan => false).where("wells.id = ?", @drilling_log.job.well_id).first
                        calculated_points_survey = @survey.calculated_points(@active_well_plan.present? && !@survey.no_well_plan ? @active_well_plan.vertical_section_azimuth : 0)
                        fill_survey @drilling_log.job, calculated_points_survey, r
                    when "railroad"
                        @active_well_plan = Survey.includes(job: :well).where(:plan => true).where("wells.id = ?", @drilling_log.job.well_id).first
                        @survey = Survey.includes(job: :well).where(:plan => false).where("wells.id = ?", @drilling_log.job.well_id).first
                        calculated_points_survey = @survey.present? ? @survey.calculated_points(@active_well_plan.present? && !@survey.no_well_plan ? @active_well_plan.vertical_section_azimuth : 0.0) : []
                        fill_railroad @drilling_log.job, @active_well_plan, calculated_points_survey, r
                    when "railroad_certification"
                        @active_well_plan = Survey.includes(job: :well).where(:plan => true).where("wells.id = ?", @drilling_log.job.well_id).first
                        @survey = Survey.includes(job: :well).where(:plan => false).where("wells.id = ?", @drilling_log.job.well_id).first
                        calculated_points_survey = @survey.present? ? @survey.calculated_points(@active_well_plan.present? && @survey.present? && !@survey.no_well_plan ? @active_well_plan.vertical_section_azimuth : 0.0) : []
                        fill_railroad_certification @drilling_log.job, @drilling_log, @active_well_plan, @survey, calculated_points_survey, r
                    when "incident_report"
                        index = type.to_i

                end
            end
            file = "#{Rails.root}/tmp/#{SecureRandom.hex}_#{@report_name}.odt"
            report.generate(file)

            #if !Rails.env.production?
            #    %x{/Applications/LibreOffice.app/Contents/MacOS/soffice --headless --invisible --convert-to pdf --outdir #{File.dirname(file)} #{file}}
            #else
            #    %x{soffice --headless --invisible --convert-to pdf --outdir #{File.dirname(file)} #{file}}
            #end
            #new_file = file[0..-4] + "pdf"

            url = "tmp/#{Time.zone.now.month}/#{@drilling_log.company_id}/#{SecureRandom.hex}/#{@report_name}.odt"
            #puts url
            s3 = AWS::S3.new
            s3.buckets['elephant-docs'].objects[url].write(File.read(file))

            puts "uploaded"

            Common::Product.setBaseProductUri("http://api.saaspose.com/v1.0")
            Common::SaasposeApp.new(ENV["SAASPOSE_APPSID"], ENV["SAASPOSE_APPKEY"])

            oldFile = "http://api.saaspose.com/v1.0/words/#{File.basename(url)}?format=pdf&storage=elephant&folder=elephant-docs/#{File.dirname(url)}"
            newFile = "http://api.saaspose.com/v1.0/storage/file/elephant-docs/#{File.dirname(url)}/#{File.basename(url, '.*')}.pdf?storage=elephant"

            RestClient.put Common::Utils.sign(newFile), open(Common::Utils.sign(oldFile)), {:accept => :json}

            pdf = s3.buckets['elephant-docs'].objects["#{File.dirname(url)}/#{File.basename(url, '.*')}.pdf"]
            @full_url = pdf.url_for(:get, {
                    expires: 1.day,
                    response_content_disposition: 'attachment;'
            }).to_s


            File.delete(file) if File.exist?(file)
            #File.delete(new_file) if File.exist?(new_file)

            $redis.set(report_id, @full_url)
            #redirect_to full_url
        end
        #send_data excel.to_stream.read, :filename => 'jobs.xlsx', :type => "application/vnd.openxmlformates-officedocument.spreadsheetml.sheet"
        #return
    end

end
