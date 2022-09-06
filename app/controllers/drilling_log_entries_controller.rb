class DrillingLogEntriesController < ApplicationController
    before_filter :signed_in_user, only: [:show, :new, :create, :edit, :update, :destroy]

    def show
        @drilling_log_entry = DrillingLogEntry.find_by_id(params[:id])
        not_found unless @drilling_log_entry.present?
    end

    def new

    end

    def create
        not_found unless params[:drilling_log_entry].present?
        drilling_log_id = params[:drilling_log_entry][:drilling_log_id]
        params[:drilling_log_entry].delete(:drilling_log_id)

        @drilling_log = DrillingLog.find_by_id(drilling_log_id)

        DrillingLogEntry.transaction do

            if params[:file_source].present?

                contents = nil
                file_data = params[:file_source]
                if file_data.respond_to?(:read)
                    contents = file_data.read
                elsif file_data.respond_to?(:path)
                    contents = File.read(file_data.path)
                else
                    logger.error "Bad file_data: #{file_data.class.name}: #{file_data.inspect}"
                    return
                end

                spreadsheet = open_spreadsheet(file_data)

                last_bha = nil
                last_date = nil
                last_wob = 0.0
                last_flow = 0.0
                last_rpm = 0.0

                DrillingLogEntry.transaction do

                    #Remove Existing Entries
                    @drilling_log.drilling_log_entries.each do |dls|
                        dls.destroy
                    end

                    headers = spreadsheet.row(6)
                    (6..spreadsheet.last_row).each do |i|
                        row = spreadsheet.row(i)
                        #if !last_date.blank?
                        #    puts last_date
                        #end
                        #puts row[0]
                        #puts row[1]
                        #puts row[2]
                        #puts row[3]
                        #puts row[4]
                        #puts row[5]

                        drilling_log_entry = DrillingLogEntry.new

                        if !row[0].blank?
                            if row[1].is_a?(Float)
                                time = DateTime.strptime("#{DateTime.new(1899, 12, 30).to_f + row[1].to_f}", '%s')
                                drilling_log_entry.entry_at = Time.zone.parse("#{row[0]} #{time.strftime("%H:%M")}")
                            elsif row[1].is_a?(String) && !row[1].blank?
                                drilling_log_entry.entry_at = Time.zone.parse("#{row[0]} #{row[1]}")
                            else
                                drilling_log_entry.entry_at = Time.zone.parse("#{row[0]} 24:00")
                            end
                            last_date = row[0]
                        else
                            if row[1].is_a?(Float)
                                time = DateTime.strptime("#{DateTime.new(1899, 12, 30).to_f + row[1].to_f}", '%s')
                                drilling_log_entry.entry_at = Time.zone.parse("#{last_date} #{time.strftime("%H:%M")}")
                            elsif row[1].is_a?(String) && !row[1].blank?
                                drilling_log_entry.entry_at = Time.zone.parse("#{last_date} #{row[1]}")
                            else
                                drilling_log_entry.entry_at = Time.zone.parse("#{last_date} 24:00}")
                            end
                        end


                        drilling_log_entry.depth = row[2]
                        drilling_log_entry.comment = row[5]
                        drilling_log_entry.activity_code = get_activity_code(row[4])
                        drilling_log_entry.drilling_log = @drilling_log
                        drilling_log_entry.company = current_user.company
                        drilling_log_entry.job = @drilling_log.job
                        drilling_log_entry.user = current_user
                        drilling_log_entry.user_name = current_user.name
                        if !row[3].blank?
                            bha = Bha.includes(job: :well).where("wells.id = ?", @drilling_log.job.well_id).where("bhas.name = ?", row[3].to_i.to_s).first
                            if bha.nil?
                                bha = Bha.new
                                bha.name = row[3].to_i.to_s
                                bha.company = current_user.company
                                bha.job = @drilling_log.job
                                bha.save
                            end
                            drilling_log_entry.bha = bha
                            last_bha = bha
                        elsif !last_bha.nil?
                            drilling_log_entry.bha = last_bha
                        end

                        if !row[6].blank?
                            drilling_log_entry.wob = row[6].to_d
                            last_wob = drilling_log_entry.wob
                        else
                            drilling_log_entry.wob = last_wob
                        end
                        if !row[7].blank?
                            drilling_log_entry.flow = row[7].to_d
                            last_flow = drilling_log_entry.flow
                        else
                            drilling_log_entry.flow = last_flow
                        end
                        if !row[8].blank?
                            drilling_log_entry.rotary_rpm = row[8].to_d
                            last_rpm = drilling_log_entry.rotary_rpm
                        else
                            drilling_log_entry.rotary_rpm = last_rpm
                        end

                        drilling_log_entry.save
                    end
                end

                @drilling_log = DrillingLog.find_by_id(drilling_log_id)
                @drilling_log.recalculate


                bhas = Bha.joins(job: :well).where("wells.id = ?", @drilling_log.job.well_id)
                bhas.each do |bha|
                    bha.delay.update_usage
                end

                redirect_to drilling_log_path(@drilling_log, anchor: :log)
                return
            else

                bha_id = params[:drilling_log_entry][:bha_id]
                params[:drilling_log_entry].delete(:bha_id)

                depth = params[:drilling_log_entry][:depth]
                params[:drilling_log_entry].delete(:depth)

                last_survey_sequence = DrillingLogEntry.where("drilling_log_entries.drilling_log_id = ?", @drilling_log.id).where("drilling_log_entries.survey_sequence IS NOT NULL").order("drilling_log_entries.entry_at DESC").limit(1).first
                if last_survey_sequence.present? && last_survey_sequence.survey_sequence == params[:drilling_log_entry][:survey_sequence]
                    params[:drilling_log_entry].delete(:survey_sequence)
                end

                last_logging_sequence = DrillingLogEntry.where("drilling_log_entries.drilling_log_id = ?", @drilling_log.id).where("drilling_log_entries.logging_sequence IS NOT NULL").order("drilling_log_entries.entry_at DESC").limit(1).first
                if last_logging_sequence.present? && last_logging_sequence.logging_sequence == params[:drilling_log_entry][:logging_sequence]
                    params[:drilling_log_entry].delete(:logging_sequence)
                end


                override_date = nil

                begin
                    date = Date.strptime("#{params[:date]}", '%m/%d/%Y')
                    override_date = Time.zone.parse("#{date.year}-#{date.month}-#{date.day} #{params[:entry_time]}")
                rescue
                end

                params[:drilling_log_entry].delete(:override_date)

                @drilling_log_entry = DrillingLogEntry.new(params[:drilling_log_entry])
                @drilling_log_entry.drilling_log = @drilling_log
                @drilling_log_entry.company = current_user.company
                @drilling_log_entry.job = @drilling_log.job
                @drilling_log_entry.user = current_user
                @drilling_log_entry.user_name = current_user.name
                @drilling_log_entry.depth = depth.to_s.gsub(/,/, '').to_f
                if !bha_id.blank?
                    @bha = Bha.find_by_id(bha_id)
                    @drilling_log_entry.bha = @bha
                end


                if override_date.nil?
                    @drilling_log_entry.entry_at = Time.zone.now
                else
                    @drilling_log_entry.entry_at = override_date
                end

            end

            entries = @drilling_log.drilling_log_entries.to_a
            entries << @drilling_log_entry
            entries = entries.sort_by { |e| e.entry_at }
            @prior_entry = nil
            entries.each do |dl|
                puts "*"
                if dl == @drilling_log_entry
                    break
                end
                @prior_entry = dl
            end


            if @prior_entry.present?
                course_length = @drilling_log_entry.depth - @prior_entry.depth
                hours = (@drilling_log_entry.entry_at - @prior_entry.entry_at) / 60 / 60
                rop = course_length / hours

                if (@drilling_log_entry.activity_code == DrillingLogEntry::DRILLING || @drilling_log_entry.activity_code == DrillingLogEntry::SLIDING) && course_length < 0
                    @drilling_log_entry.errors.add(:depth, "can't be a negative value based on the last entry. Rotating or sliding activities must be deeper than the last greatest depth. Depth change from last activity: #{course_length} ft.")
                    return
                end

                if (@drilling_log_entry.activity_code == DrillingLogEntry::DRILLING || @drilling_log_entry.activity_code == DrillingLogEntry::SLIDING) && rop > 2000
                    @drilling_log_entry.errors.add(:depth, "can't jump to a value this deep within the specific time period. Maybe there a problem with the depth or time.<br><br>Time difference is #{hours.round(2)} hrs and ROP is #{rop.round(2)} ft/hr based on new depth of #{@drilling_log_entry.depth } ft")
                    return
                end

                if (@drilling_log_entry.activity_code == DrillingLogEntry::CONNECTION || @drilling_log_entry.activity_code == DrillingLogEntry::CONNECTION_SURVEY) && course_length != 0
                    @drilling_log_entry.errors.add(:depth, "change must be equal to zero for connections. The depth should be equal to the last depth of activity.")
                    return
                end
            end

            if @drilling_log_entry.save

                @drilling_log = DrillingLog.find_by_id(@drilling_log.id)
                @drilling_log.recalculate
                @drilling_log_entry = DrillingLogEntry.find_by_id(@drilling_log_entry.id)

                if @drilling_log_entry.present? && @drilling_log_entry.bha.present?
                    @drilling_log_entry.bha.delay.update_usage
                end

                @drilling_log.delay.start_on_job_phase

                @last_entry = @drilling_log.drilling_log_entries.last
                @drilling_log.drilling_log_entries.each do |dl|
                    if dl == @drilling_log_entry
                        break
                    end
                    @last_entry = dl
                end

                if @last_entry.nil?
                    @last_entry = @drilling_log_entry
                end

                if params[:measured_depth].present? && !params[:measured_depth].blank?
                    @survey_accepted = true
                    begin
                        if params[:inclination].blank? || params[:azimuth].blank?
                            @survey_accepted = false
                        else
                            @survey = Survey.find_by_id(params[:survey_id])
                            @survey_point = SurveyPoint.new(params[:survey_point])
                            @survey_point.survey = @survey
                            @survey_point.company = current_user.company
                            @survey_point.user = current_user
                            @survey_point.user_name = current_user.name
                            @survey_point.measured_depth = params[:measured_depth].to_s.gsub(/,/, '').to_f
                            @survey_point.inclination = params[:inclination]
                            @survey_point.azimuth = params[:azimuth]
                            @survey_point.magnetic_field_strength = params[:magnetic_field_strength]
                            @survey_point.magnetic_dip_angle = params[:magnetic_dip_angle]
                            @survey_point.gravity_total = params[:gravity_total]
                            @survey_point.comment = params[:comment]

                            last_survey = @survey.survey_points.last
                            if last_survey.present? && last_survey.measured_depth == @survey_point.measured_depth
                                @survey_accepted = false
                                return
                            else
                                @survey_point.save
                            end
                        end
                    rescue
                    end
                end
            end
        end
    end

    def edit
        @drilling_log_entry = DrillingLogEntry.find_by_id(params[:id])
    end

    def update
        @drilling_log_entry = DrillingLogEntry.find_by_id(params[:id])

        bha_id = params[:drilling_log_entry][:bha_id]
        params[:drilling_log_entry].delete(:bha_id)

        DrillingLogEntry.transaction do
            if params[:drilling_log_entry][:depth].present? &&
                    params[:drilling_log_entry][:activity_code].present?
                depth = params[:drilling_log_entry][:depth]
                params[:drilling_log_entry].delete(:depth)
                @drilling_log_entry.depth = depth.to_s.gsub(/,/, '').to_f
                @drilling_log_entry.bha = Bha.find_by_id(bha_id)
                @drilling_log_entry.update_attributes(params[:drilling_log_entry])
                @drilling_log_entry.save
            else
                @drilling_log_entry.errors.add(:drilling_log_entry, "fields can't be empty")
                return
            end

            begin
                date = Date.strptime("#{params[:date]}", '%m/%d/%Y')
                override_date = Time.zone.parse("#{date.year}-#{date.month}-#{date.day} #{params[:entry_time]}")
                @drilling_log_entry.update_attribute(:entry_at, override_date)
            rescue
            end

            @drilling_log_entry.drilling_log.recalculate
            if @drilling_log_entry.bha.present?
                @drilling_log_entry.bha.delay.update_usage
            end
        end
    end

    def destroy
        @drilling_log_entry = DrillingLogEntry.find_by_id(params[:id])
        not_found unless @drilling_log_entry.present?
        @drilling_log_entry.destroy
        @drilling_log_entry.drilling_log.recalculate

        if @drilling_log_entry.bha.present?
            @drilling_log_entry.bha.delay.update_usage
        end
    end


    private
    def open_spreadsheet(file)
        case File.extname(file.original_filename)
            when ".csv" then
                Roo::Csv.new(file.path, nil, :ignore)
            when ".xls" then
                Roo::Excel.new(file.path, nil, :ignore)
            when ".xlsx" then
                Roo::Excelx.new(file.path, nil, :ignore)
            else
                raise "Unknown file type: #{file.original_filename}"
        end
    end

    def get_activity_code value
        if value.nil?
            return DrillingLogEntry::OTHER
        end
        case value.upcase
            when "DRILLING"
                DrillingLogEntry::DRILLING
            when "SLIDING"
                DrillingLogEntry::SLIDING
            when "CIRCULATING"
                DrillingLogEntry::CIRCULATING
            when "CONNECTION & SURVEY"
                DrillingLogEntry::CONNECTION_SURVEY
            when "REAMING"
                DrillingLogEntry::REAMING
            when "CEMENTING"
                DrillingLogEntry::CEMENTING
            when "CHANGE MUD"
                DrillingLogEntry::CHANGE_MUD
            when "CHANGE BHA"
                DrillingLogEntry::CHANGE_BHA
            when "POOH"
                DrillingLogEntry::POOH
            when "SHORT TRIP"
                DrillingLogEntry::SHORT_TRIP
            when "TIH"
                DrillingLogEntry::TIH
            when "TIH CIRCULATING"
                DrillingLogEntry::TIH_CIRCULATING
            when "WIRELINE"
                DrillingLogEntry::WIRELINE
            when "WORK PIPE"
                DrillingLogEntry::WORK_PIPE
            when "BOP DRILL"
                DrillingLogEntry::BOP_DRILL
            when "MWD SURVEY"
                DrillingLogEntry::MWD_SURVEY
            when "L/D DP"
                DrillingLogEntry::LD_DP
            when "P/U DP"
                DrillingLogEntry::PU_DP
            when "DRILLING CEMENT"
                DrillingLogEntry::DRILLING_CEMENT
            when "LOGGING"
                DrillingLogEntry::LOGGING
            when "CONNECTION"
                DrillingLogEntry::CONNECTION
            when "JETTING"
                DrillingLogEntry::JETTING

            when "UNDEFINED"
                DrillingLogEntry::OTHER
            when "RIG REPAIR"
                DrillingLogEntry::RIG_REPAIR
            when "PIPE STUCK"
                DrillingLogEntry::PIPE_STUCK
            when "FISHING"
                DrillingLogEntry::FISHING
            when "RIG SERVICE INHOLE"
                DrillingLogEntry::RIG_SERVICE_INHOLE
            when "WAIT ON WEATHER"
                DrillingLogEntry::WAIT_ON_WEATHER
            when "TROUBLESHOOT MWD"
                DrillingLogEntry::TROUBLESHOOT_MWD


            when "NIPPLE U/D BOPS"
                DrillingLogEntry::NIPPLE_BOPS
            when "TEST BOPS"
                DrillingLogEntry::TEST_BOPS
            when "SURFACE TEST MWD"
                DrillingLogEntry::SURFACE_TEST_MWD

            when "STANDBY"
                DrillingLogEntry::STANDBY_OUTHOLE
            when "RIG SERVICE OUTHOLE"
                DrillingLogEntry::RIG_SERVICE_OUTHOLE

            else
                DrillingLogEntry::OTHER
        end
    end


end
