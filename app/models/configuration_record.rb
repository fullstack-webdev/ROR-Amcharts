class ConfigurationRecord
    attr_reader :json,
                :template_name,
                :well_name,
                :rig_name,
                :date,
                :entry_at,
                :well,
                :job,
                :drill_strings,
                :bha,
                :bit,
                :casings,
                :fluid,
                :surveys


    def initialize(json, user)
        @json = json

        if @json != nil
            @template_name = @json["TemplateName"]
            @well_name = @json["WellNameBlock"].strip
            @rig_name = @json["RigNameBlock"].gsub("Rig", "").strip
            @date = @json["DateBlock"]

            @entry_at = DateTime.strptime(@date + " 6:00:00 +006", "%m/%d/%Y %H:%M:%S %Z")

            drill_pipe_block = @json["DrillPipeAndCollarsBlock"]
            @drill_strings = parse_drill_pipe_block(drill_pipe_block)

            bha_block = @json["BhaBlock"]
            bhas = parse_bha_block(bha_block)
            @bha = bhas.last

            if @bha != nil
                @drill_strings << @bha
            end

            @drill_strings.each_with_index do |ds, index|
                ds.position = index
                puts ds.type + " " + ds.length.to_s
            end

            bit_block = @json["BitBlock"]
            bits = parse_bit_block(bit_block)
            @bit = bits.last

            casing_block = @json["CasingBlock"]
            @casings = parse_casing_block(casing_block)

            fluid_block = @json["MudBlock"]
            if fluid_block.strip.present?
                @fluid = parse_fluid_block(fluid_block).last
            end

            surveys_block = @json["SurveysBlock"]
            @surveys = parse_surveys_block(surveys_block)

            @well = Well.includes(:rig).where("wells.company_id = ?", user.company_id).where("rigs.company_id = ?", user.company_id).where("rigs.name ~* ?", @rig_name).where("wells.name ~* ?", @well_name).limit(1).try(:first)
            if @well
                @job = @well.jobs.first
            end


        end
    end

    def compare_to_last_drill_string last_date

        drill_strings = DrillingString.where(:job_id => @job.id, :entry_at => last_date).order(:position)
        casings = Casing.where(:job_id => @job.id, :entry_at => last_date)
        bit = Bit.where("job_id = #{@job.id} AND entry_at <= TO_DATE('#{@entry_at.in_time_zone(Time.zone).strftime('%m/%d/%Y %H:%M:%S')}', 'MM/DD/YYYY HH24:MI:SS AM')").order("entry_at DESC").limit(1).first

        different = false

        if @drill_strings != nil
            if @bha == nil
                @bha = drill_strings.last
                if @bha != nil
                    @drill_strings << @bha
                end
            end
        end

        if @drill_strings == nil
            @drill_strings = drill_strings.to_a
        end

        if @drill_strings.length == drill_strings.length
            drill_strings.each_with_index do |ds, index|
                if !ds.identical? @drill_strings[index]
                    different = true
                    break
                end
            end
        else
            different = true
        end

        if @casings.length == casings.length
            casings.each_with_index do |c, index|
                if !c.identical? @casings[index]
                    different = true
                    break
                end
            end
        else
            different = true
        end

        if @bit == nil
            @bit = bit
        end

        if bit != nil && !bit.identical?(@bit)
            different = true
        end


        if different
            save_drill_string_record
        end
    end

    def save_drill_string_record
        bit_sizes = Bit.where(:job_id => @job.id).order(:size, :in_depth)

        @drill_strings.each do |ds|
            ds.job = @job
            if ds.company.nil?
                ds.company = @job.company
            end
            ds.entry_at = @entry_at
            if !ds.save
                puts ds.errors.full_messages.join(" ")
            else
                puts "saved ds"
            end
        end

        @casings.each do |c|
            c.job = @job
            if c.company.nil?
                c.company = @job.company
            end
            c.entry_at = @entry_at
            c.save
            puts "saved casing"
        end


        if @bit != nil
            bit = @bit
            puts bit.size
            bit.job = @job
            if bit.company.nil?
                bit.company = @job.company
            end
            bit.entry_at = @entry_at
            puts bit.entry_at
            if !bit.save
                puts bit.errors.full_messages.join(" ")
            else
                puts "saved bit"
            end
        else
            puts "Bit problem"
        end

        if false and bit_sizes != nil
            bit_sizes = bit_sizes.to_a
            if bit_sizes.select { |b| b.size == bit.size }.empty?
                bit_sizes << bit
            end

            bit_sizes.each do |bs|
                hole_size = HoleSize.new
                hole_size.job = @job
                hole_size.company = @job.company
                hole_size.entry_at = @entry_at
                hole_size.diameter = bs
                hole_size.save
            end
        end

    end


    def compare_to_last_fluid last_date

        fluid = Fluid.where(:job_id => @job.id, :entry_at => last_date).last

        different = false

        if @fluid == nil
            @fluid = fluid
        end

        if !fluid.identical? @fluid
            different = true
        end


        if different
            save_fluid_record
        end
    end

    def save_fluid_record

        fluid = @fluid
        fluid.job = @job
        if fluid.company.nil?
            fluid.company = @job.company
        end
        fluid.entry_at = @entry_at
        if !fluid.save
            puts fluid.errors.full_messages.join(" ")
        else
            puts "fluid saved"
        end

    end


    def parse_drill_pipe_block(drill_pipe_block)
        drill_strings = []

        lines = drill_pipe_block.split("\r\n")
        lines.delete_at(0)
        lines.delete_at(0)
        lines.each do |l|
            if l.strip.present? && l.split(" ").length > 3
                begin
                    drill_string = DrillingString.new

                    puts l

                    start = 0
                    length = 6
                    count = l[start..(start+length)].strip
                    start += length + 1
                    length = 6
                    drill_string.length = l[start..(start+length)].strip.gsub(",", "").to_f
                    if drill_string.length == nil
                        drill_string.length = 0
                    end
                    start += length + 1
                    length = 7
                    drill_string.outer_diameter = l[start..(start+length)].strip
                    start += length + 1
                    length = 8
                    drill_string.weight = l[start..(start+length)].strip
                    start += length + 1
                    length = 8
                    drill_string.inner_diameter = l[start..(start+length)].strip
                    if drill_string.inner_diameter == nil && drill_strings.any?
                        drill_string.inner_diameter = drill_strings.last.inner_diameter
                    end

                    start += length + 1
                    length = 6
                    drill_string.type = l[start..(start+length)].strip

                    drill_strings << drill_string
                end
            end
        end

        return drill_strings
    end

    def parse_bit_block(bit_block)
        bits = []

        lines = bit_block.split("\r\n")
        if lines.any? && lines[0].strip.downcase == "bit"
            lines.delete_at(0)
            lines.delete_at(0)
            lines.each do |l|
                if l.strip.present?
                    begin
                        if l.length > 30 && l[0..20].strip.empty?

                            bit = bits.last

                            start = 0
                            length = 4
                            start += length + 1
                            length = 8
                            start += length + 1
                            length = 7

                            start += length + 1
                            length = 6
                            start += length + 1
                            length = 7
                            make1 = nil
                            make2 = nil
                            if l.length >= (start+length)
                                make1 = l[start..(start+length)].strip
                            end
                            start += length + 1
                            length = 9
                            if l.length >= (start+length)
                                make2 = l[start..(start+length)].strip
                            end
                            start += length + 1
                            length = 12
                            serial = ''
                            if l.length >= (start+length)
                                serial = l[start..(start+length)].strip
                            end

                            if make1.present? || make2.present?
                                parts = bit.make.split('-')
                                bit.make = parts[0].strip + make1 + ' - ' + parts[1].strip + make2
                            end

                            if serial.present?
                                bit.serial += serial
                            end


                            puts "Bit"
                            puts "............"
                            puts bit.size
                            puts bit.make
                            puts bit.serial_no
                            puts bit.jets
                            puts bit.tfa

                        else
                            bit = Bit.new

                            puts "Bit"
                            puts "............"

                            start = 0
                            length = 4
                            bit.number = l[start..(start+length)].strip
                            puts bit.number

                            start += length + 1
                            length = 8
                            bit.depth_from = l[start..(start+length)].strip.gsub(",", "").to_f
                            bit.in_depth = bit.depth_from
                            start += length + 1
                            length = 7
                            bit.depth_to = l[start..(start+length)].strip.gsub(",", "").to_f

                            start += length + 1
                            length = 6
                            bit.size = l[start..(start+length)].strip.to_f
                            puts bit.size
                            start += length + 1
                            length = 7
                            bit.make = l[start..(start+length)].strip
                            puts bit.make
                            start += length + 1
                            length = 9
                            bit.make += ' - ' + l[start..(start+length)].strip
                            puts bit.make
                            start += length + 1
                            length = 12
                            bit.serial_no = l[start..(start+length)].strip
                            puts bit.serial_no
                            start += length + 1
                            length = 7
                            bit.jets = l[start..(start+length)].strip
                            puts bit.jets
                            start += length + 1
                            length = 7
                            bit.nozzle_size = l[start..(start+length)].strip

                            bit.tfa = (bit.jets || 1).to_f * (Math::PI / 4.0).to_f * (((bit.nozzle_size || 0) / 32.0).to_f ** 2.0).to_f
                            puts bit.tfa


                            bits << bit
                        end

                    end
                end
            end
        end

        return bits
    end


    def parse_bha_block(bha_block)

        drill_strings = []

        lines = bha_block.split("\r\n")
        lines.delete_at(0)
        lines.each do |l|
            if l.strip.present?
                begin
                    drill_string = DrillingString.new


                    start = 0
                    length = 8
                    bha_number = l[start..(start+length)].strip
                    start += length + 1
                    length = 9
                    drill_string.length = l[start..(start+length)].strip.gsub(",", "").to_f
                    start += length + 1
                    length = 6
                    drill_string.weight = l[start..(start+length)].strip.to_d
                    start += length + 1

                    drill_string.outer_diameter = 8.0
                    drill_string.inner_diameter = 5.0

                    bha = l[start..-1].strip
                    drill_string.type = "BHA"

                    drill_strings << drill_string

                end
            end
        end

        return drill_strings
    end

    def parse_surveys_block(surveys_block)
        surveys = []

        lines = surveys_block.split("\r\n")
        lines.delete_at(0)
        lines.delete_at(0)
        lines.each do |l|
            if l.strip.present? && l.split(" ").length > 2
                begin
                    puts "Survey"
                    survey_point = SurveyPoint.new

                    start = 0
                    length = 17
                    type = l[start..(start+length)].strip
                    start += length + 1
                    length = 16
                    survey_point.measured_depth = l[start..(start+length)].strip.gsub(",", "").to_f
                    start += length + 1
                    length = 11
                    survey_point.inclination = l[start..(start+length)].strip.to_f
                    start += length + 1
                    length = 8
                    if l.length > (start + length)
                        survey_point.azimuth = l[start..(start+length)].strip.to_f
                        start += length + 1
                        survey_point.dog_leg_severity = l[start..-1].strip
                    else
                        survey_point.azimuth = 0
                    end

                    puts "MD #{survey_point.measured_depth}  Az #{survey_point.azimuth}  Inc #{survey_point.inclination}"

                    surveys << survey_point
                end
            end
        end

        return surveys
    end


    def parse_casing_block(casing_block)
        casings = []

        lines = casing_block.split("\r\n")
        lines.delete_at(0)
        lines.delete_at(0)
        while lines.length > 0
            begin
                if lines.length >= 3
                    line1 = lines.delete_at(0)
                    line2 = lines.delete_at(0)
                    line3 = lines.delete_at(0)

                    begin
                        puts "Casing"
                        casing = Casing.new

                        parts = line1.split(" ")
                        casing.inner_diameter = parts[0].strip

                        if parts.length == 2
                            shoe_test = parts[1].strip
                        end

                        casing.depth_from = 0.0
                        parts2 = line2.split(" ")
                        if parts2.length > 1
                            casing.depth_from = parts2[0].strip.gsub(",", "")
                            casing.length = parts2[1].strip.gsub(",", "").to_f
                            casing.depth_to = casing.length
                        end

                        puts casing.depth_from
                        puts casing.depth_to
                        puts casing.length


                        if parts2.length > 4
                            weight = parts2[3].strip
                            grade = parts2[4].strip
                        end

                        if parts.length > 5
                            toc = parts2[5].strip
                        end

                        date = line3.strip

                        casings << casing
                    end

                end
            end
        end

        return casings
    end


    def parse_fluid_block(fluid_block)
        fluids = []

        lines = fluid_block.split("\r\n")
        lines.delete_at(0)
        lines.delete_at(0)
        l = lines[0]
        if l.strip.present? && l.split(" ").length > 3
            begin
                fluid = Fluid.new

                start = 0
                length = 9
                mud_type = l[start..(start+length)].strip.downcase
                fluid.type = "0"
                if mud_type == "obm"
                    fluid.type = "1"
                end
                start += length + 1
                length = 8
                fluid.density = l[start..(start+length)].strip
                start += length + 1
                length = 8
                ecd = l[start..(start+length)].strip
                start += length + 1
                length = 7
                fluid.funnel_viscosity = l[start..(start+length)].strip
                start += length + 1
                length = 8
                if l.length >= start
                    fluid.pv = l[start..(start+length)].strip
                    start += length + 1
                    length = 8
                    fluid.yp = l[start..(start+length)].strip

                    start += length + 1
                    length = 10
                    if l.length >= start
                        fluid.seconds10 = l[start..(start+length)].strip
                        start += length + 1
                        length = 11
                        fluid.minutes10 = l[start..(start+length)].strip
                    end
                end

                fluids << fluid
            end
        end

        return fluids
    end


end