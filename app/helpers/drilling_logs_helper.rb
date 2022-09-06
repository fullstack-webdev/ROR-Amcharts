module DrillingLogsHelper

    include ActionView::Helpers::NumberHelper


    def fill_run_report job, entries, r, start_time, end_time, run_number
        fill_drilling_report job, entries, r, start_time, end_time

        if run_number == 0
            r.add_field "RUN_NAME", "ALL RUNS"
        else
            r.add_field "RUN_NAME", "RUN #{run_number}"
        end

        bhas = entries.select { |e| e.bha.present? }.group_by { |e| e.bha_id }
        if bhas.count == 1 && bhas[0].present?
            r.add_field "BHA1", "#{bhas[0].name}"
            r.add_field "BHA1_DESC", "#{bhas[0].description}"
        else
            r.add_field "BHA1", "-"
            r.add_field "BHA1_DESC", ""
        end
    end

    def fill_bha_report job, entries, r, start_time, end_time, bha, run_number
        fill_drilling_report job, entries, r, start_time, end_time

        r.add_field "BHA_NAME", "BHA # #{bha.name} - #{bha.description}"
        r.add_field "RUN", "#{run_number}"


        last_index = 0
        depth = 0.0
        items = bha.bha_items.to_a

        (11 - last_index).times do
            last_index = last_index + 1
            r.add_field "A#{last_index + 1}", ""
            r.add_field "ID#{last_index + 1}", ""
            r.add_field "OD#{last_index + 1}", ""
            r.add_field "L#{last_index + 1}", ""
            r.add_field "LT#{last_index + 1}", ""
            r.add_field "TC#{last_index + 1}", ""
        end

        white_fill = Magick::GradientFill.new(0, 0, 0, 0, "#FFFFFF", "#FFFFFF")
        # 1.38, 7.94
        dst = Magick::Image.new(1.38 * 150, 7.94 * 150, white_fill)

        top = 20
        height = 0
        items.reverse.each_with_index do |bha_item, index|

            if bha_item.up.present? && bha_item.up > 0 && bha_item.up <= 10
                src = Magick::Image.read("app/assets/images/bha/pin_up.png")[0]
                height = 16
                dst = dst.composite(src, Magick::NorthGravity, 0, top, Magick::OverCompositeOp)
                top += height
            end

            src = Magick::Image.read("app/assets/images/bha/other.png")[0]
            height = 83

            case bha_item.asset_type
                when BhaItem::BIT
                    src = Magick::Image.read("app/assets/images/bha/bit.png")[0]
                    height = 58
                when BhaItem::MOTOR
                    src = Magick::Image.read("app/assets/images/bha/motor.png")[0]
                    height = 204
                when BhaItem::STABILIZER
                    src = Magick::Image.read("app/assets/images/bha/stabilizer.png")[0]
                    height = 115
                when BhaItem::UBHO_SUB
                when BhaItem::DRILL_COLLAR
                    src = Magick::Image.read("app/assets/images/bha/drill_collar.png")[0]
                    height = 159
                else
                    src = Magick::Image.read("app/assets/images/bha/other.png")[0]
                    height = 83
            end

            dst = dst.composite(src, Magick::NorthGravity, 0, top, Magick::OverCompositeOp)
            top += height

            #text = Magick::Draw.new
            #dst.annotate(text, 0,0,0, top, bha_item.tool.name) do
            #    text.gravity = Magick::NorthEastGravity
            #    self.pointsize = 12
            #end

            if bha_item.down.present? && bha_item.down > 0 && bha_item.down <= 10
                src = Magick::Image.read("app/assets/images/bha/pin_down.png")[0]
                height = 16
                dst = dst.composite(src, Magick::NorthGravity, 0, top, Magick::OverCompositeOp)
                top += height
            end
        end

        file_path = "#{Rails.root}/tmp/bha.png"
        dst.write(file_path)
        r.add_image "BHA", file_path
    end

    def fill_drilling_report job, entries, r, start_time, end_time

        drilling_log = DrillingLog.calculate entries
        r.add_field "JOB_NAME", job.field.name + ' - ' + job.well.name
        r.add_field "JOB_NUMBER", 'Job # ' + (job.job_number || '-')
        r.add_field "RIG", 'Rig ' + (job.well.rig.present? ? job.well.rig.name : '-')
        r.add_field "CLIENT", job.company.name

        hours = (end_time - start_time).to_f / 60.0 / 60.0
        if hours <= 24
            r.add_field "TIME", "#{start_time.strftime('%m/%d/%Y')} (#{hours.ceil.to_i} hours)"
        else
            days = (hours / 24.0).round(0).to_i
            r.add_field "TIME", "#{start_time.strftime('%m/%d/%Y')} - #{end_time.strftime('%m/%d/%Y')} (#{days} #{"day".pluralize(days)})"
        end


        r.add_field "T1", drilling_log.drilling_rop.nil? ? "-" : drilling_log.drilling_rop.round(1)
        r.add_field "T2", drilling_log.total_drilled.nil? ? "-" : number_with_delimiter(drilling_log.total_drilled.to_i, :delimiter => ',')
        r.add_field "T3", drilling_log.drilling_time.nil? ? "-" : drilling_log.drilling_time.round(1)
        r.add_field "T4", drilling_log.npt.nil? ? "-" : drilling_log.npt.round(1)
        r.add_field "T6", "#{number_with_delimiter(drilling_log.start_depth.to_i, :delimiter => ',')} - #{number_with_delimiter(drilling_log.end_depth.to_i, :delimiter => ',')}"

        bhas = entries.select { |e| e.bha.present? }.group_by { |e| e.bha_id }
        r.add_field "T7", bhas.count

        runs = DrillingLog.new.get_runs(entries)
        r.add_field "T8", runs.count


        range_cost = JobCost.includes(:job).where("jobs.well_id = ?", job.well_id).where("job_costs.charge_at >= :start_time AND job_costs.charge_at <= :end_time", start_time: start_time, end_time: end_time).map { |jc| jc.price * jc.quantity }.reduce(:+)
        total_cost = job.well.jobs.sum("jobs.total_cost").to_f
        r.add_field "C1", range_cost.nil? ? '-' : number_to_currency(range_cost, :unit => "$")
        r.add_field "C2", number_to_currency(total_cost, :unit => "$")


        r.add_field "R1", drilling_log.rotary_footage_pct.nil? ? "-" : (drilling_log.rotary_footage_pct * 100).round(1)
        r.add_field "R2", drilling_log.rotary_hours_pct.nil? ? "-" : (drilling_log.rotary_hours_pct * 100).round(1)
        r.add_field "R3", drilling_log.rotate_rop.nil? ? "-" : drilling_log.rotate_rop.round(1)
        r.add_field "R4", drilling_log.rotate_footage.nil? ? "-" : number_with_delimiter(drilling_log.rotate_footage.to_i, :delimiter => ',')
        r.add_field "R5", drilling_log.rotate_hours.nil? ? "-" : drilling_log.rotate_hours.round(1)

        r.add_field "S1", drilling_log.slide_footage_pct.nil? ? "-" : (drilling_log.slide_footage_pct * 100).round(1)
        r.add_field "S2", drilling_log.slide_hours_pct.nil? ? "-" : (drilling_log.slide_hours_pct * 100).round(1)
        r.add_field "S3", drilling_log.slide_rop.nil? ? "-" : drilling_log.slide_rop.round(1)
        r.add_field "S4", drilling_log.slide_footage.nil? ? "-" : number_with_delimiter(drilling_log.slide_footage.to_i, :delimiter => ',')
        r.add_field "S5", drilling_log.slide_hours.nil? ? "-" : drilling_log.slide_hours.round(1)

        bhas.each_with_index do |bha_group, index|
            bha = Bha.find_by_id(bha_group[0])
            bha_entries = bha_group[1]
            r.add_field "BHA#{index + 1}", "BHA #{bha.name}"
            r.add_field "BHA#{index + 1}_DESC", "#{bha.description}"
            r.add_field "B#{index + 1}_TIME", "#{bha_entries.first.entry_at.strftime('%m/%d %H:%M %p')} - #{bha_entries.last.entry_at.strftime('%m/%d %H:%M %p')}"
        end

        if bhas.count < 3
            r.add_field "BHA3", ""
            r.add_field "BHA3_DESC", ""
            r.add_field "B3_TIME", ""
        end
        if bhas.count < 2
            r.add_field "BHA2", ""
            r.add_field "BHA2_DESC", ""
            r.add_field "B2_TIME", ""
        end
        if bhas.count < 1
            r.add_field "BHA1", ""
            r.add_field "BHA1_DESC", ""
            r.add_field "B1_TIME", ""
        end


        r.add_field "H1", "Drilling Parameters"
        r.add_field "P1", "Start Depth"
        r.add_field "V1", "#{drilling_log.start_depth.to_i} ft"
        r.add_field "P2", "End Depth"
        r.add_field "V2", "#{drilling_log.end_depth.to_i} ft"
        r.add_field "P3", "In-Hole"
        r.add_field "V3", "#{drilling_log.below_rotary.present? ? drilling_log.below_rotary.round(1) : 0.0} hrs"
        r.add_field "P4", "Out-Hole"
        r.add_field "V4", "#{drilling_log.above_rotary.present? ? drilling_log.above_rotary.round(1) : 0.0} hrs"
        r.add_field "P5", "Circulation"
        r.add_field "V5", "#{drilling_log.circulation_hours.present? ? drilling_log.circulation_hours.round(1) : 0.0} hrs"
        r.add_field "P6", "Reaming"
        r.add_field "V6", "#{drilling_log.ream_hours.present? ? drilling_log.ream_hours.round(1) : 0.0} hrs"

        if drilling_log.ranges.present?
            r.add_field "P7", "WOB"
            r.add_field "V7", range_span(drilling_log.ranges["wob_min"], drilling_log.ranges["wob_max"]) + " lbs"
            r.add_field "P8", "Rotate Weight"
            r.add_field "V8", range_span(drilling_log.ranges["rotary_weight_min"], drilling_log.ranges["rotary_weight_max"]) + " lbs"
            r.add_field "P9", "P/U Weight"
            r.add_field "V9", range_span(drilling_log.ranges["pu_weight_min"], drilling_log.ranges["pu_weight_max"]) + " lbs"
            r.add_field "P10", "S/O Weight"
            r.add_field "V10", range_span(drilling_log.ranges["so_weight_min"], drilling_log.ranges["so_weight_max"]) + " lbs"
            r.add_field "P11", "SPP"
            r.add_field "V11", range_span(drilling_log.ranges["spp_min"], drilling_log.ranges["spp_max"]) + " psi"
            r.add_field "P12", "Flow Rate"
            r.add_field "V12", range_span(drilling_log.ranges["flow_min"], drilling_log.ranges["flow_max"]) + " g/m"

            r.add_field "P13", "Rotary RPM"
            r.add_field "V13", range_span(drilling_log.ranges["rotary_rpm_min"], drilling_log.ranges["rotary_rpm_max"]) + " rpm"
            r.add_field "P14", "Motor RPM"
            r.add_field "V14", range_span(drilling_log.ranges["motor_rpm_min"], drilling_log.ranges["motor_rpm_max"]) + " rpm"
            r.add_field "P15", "Torque"
            r.add_field "V15", range_span(drilling_log.ranges["torque_min"], drilling_log.ranges["torque_max"])
            r.add_field "P16", "Avg Diff Pressure"
            r.add_field "V16", range_span(drilling_log.ranges["diff_pressure_min"], drilling_log.ranges["diff_pressure_max"]) + " psi"
            r.add_field "P17", "Stall Pressure"
            r.add_field "V17", range_span(drilling_log.ranges["stall_min"], drilling_log.ranges["stall_max"]) + " psi"
            r.add_field "P18", ""
            r.add_field "V18", ""

            r.add_field "H2", "Mud Parameters"
            r.add_field "PP1", "Mud Type"
            r.add_field "VV1", DrillingLogEntry.get_mud_value_string(drilling_log.ranges["mud_type_max"])
            r.add_field "PP2", "Mud Weight"
            r.add_field "VV2", range_span(drilling_log.ranges["mud_weight_min"], drilling_log.ranges["mud_weight_max"]) + " lbs"
            r.add_field "PP3", "Viscosity"
            r.add_field "VV3", range_span(drilling_log.ranges["viscosity_min"], drilling_log.ranges["viscosity_max"])
            r.add_field "PP4", "Chlorides"
            r.add_field "VV4", range_span(drilling_log.ranges["chlorides_min"], drilling_log.ranges["chlorides_max"])
            r.add_field "PP5", "Water Loss"
            r.add_field "VV5", range_span(drilling_log.ranges["water_loss_min"], drilling_log.ranges["water_loss_max"])

            r.add_field "PP6", "YP"
            r.add_field "VV6", range_span(drilling_log.ranges["yp_min"], drilling_log.ranges["yp_max"])
            r.add_field "PP7", "PV"
            r.add_field "VV7", range_span(drilling_log.ranges["pv_min"], drilling_log.ranges["pv_max"])
            r.add_field "PP8", "PH"
            r.add_field "VV8", range_span(drilling_log.ranges["ph_min"], drilling_log.ranges["ph_max"])
            r.add_field "PP9", "BH Temp"
            r.add_field "VV9", range_span(drilling_log.ranges["bh_temp_min"], drilling_log.ranges["bh_temp_max"])
            r.add_field "PP10", "Flow Line Temp"
            r.add_field "VV10", range_span(drilling_log.ranges["fl_temp_min"], drilling_log.ranges["fl_temp_max"])

            r.add_field "PP11", "Gas %"
            r.add_field "VV11", range_span(drilling_log.ranges["gas_min"], drilling_log.ranges["gas_max"])
            r.add_field "PP12", "Sand %"
            r.add_field "VV12", range_span(drilling_log.ranges["sand_min"], drilling_log.ranges["sand_max"])
            r.add_field "PP13", "Solids %"
            r.add_field "VV13", range_span(drilling_log.ranges["solids_min"], drilling_log.ranges["solids_max"])
            r.add_field "PP14", "Oil %"
            r.add_field "VV14", range_span(drilling_log.ranges["oil_min"], drilling_log.ranges["oil_max"])
            r.add_field "PP15", ""
            r.add_field "VV15", ""

            r.add_field "H3", "Pumps"
            r.add_field "PPP1", "Liner Size"
            r.add_field "VVV1", "-"
            r.add_field "PPP2", "Stroke Length"
            r.add_field "VVV2", "-"
            r.add_field "PPP3", "Gallons/Stroke"
            r.add_field "VVV3", "-"
            r.add_field "PPP4", "Barrels/Stroke"
            r.add_field "VVV4", "-"
            r.add_field "PPP5", "Efficiency"
            r.add_field "VVV5", ""
            r.add_field "PPP6", ""
            r.add_field "VVV6", ""

            r.add_field "H4", "MWD"
            r.add_field "PPP7", "Battery AHR"
            r.add_field "VVV7", range_span(drilling_log.ranges["battery_ahr_max"], drilling_log.ranges["battery_ahr_min"]) + " ahr"
            r.add_field "PPP8", "Battery Volts"
            r.add_field "VVV8", range_span(drilling_log.ranges["battery_volts_min"], drilling_log.ranges["battery_volts_max"]) + " volts"
            r.add_field "PPP9", ""
            r.add_field "VVV9", ""
        else

        end

    end


    def fill_log job, entries, r, start_time, end_time
        r.add_field "JOB_NAME", job.field.name + ' - ' + job.well.name
        r.add_field "JOB_NUMBER", 'Job # ' + (job.job_number || '-')
        r.add_field "RIG", 'Rig ' + (job.well.rig.present? ? job.well.rig.name : '-')
        r.add_field "CLIENT", job.company.name
        hours = (end_time - start_time).to_f / 60.0 / 60.0
        if hours <= 24
            r.add_field "TIME_SPAN", "#{start_time.strftime('%m/%d/%Y')} (#{hours.ceil.to_i} hours)"
        else
            days = (hours / 24.0).round(0).to_i
            r.add_field "TIME_SPAN", "#{start_time.strftime('%m/%d/%Y')} - #{end_time.strftime('%m/%d/%Y')} (#{days} #{"day".pluralize(days)})"
        end

        last_entry = entries.first
        index = 0
        to_add = []
        entries.each_with_index do |entry, i|
            entry.last_entry = last_entry
            if entries.length > i + 1
                entry.next_entry = entries[i + 1]
            end
            last_entry = entry
        end

        index = 0
        r.add_table("TABLE", entries, :header => false) do |t|

            if false
                t.add_column("TIME") { |entry| "#{entry.entry_at.strftime("%a %d")}" }
                t.add_column("SPAN") { " " }
                t.add_column("DEPTH") { " " }
                t.add_column("DELTA") { " " }
                t.add_column("ACTIVITY") { " " }
                t.add_column("COMMENT") { " " }
                t.add_column("BHA") { " " }
            else
                t.add_column("TIME") do |entry|
                    if entry.next_entry.present? && entry.next_entry.entry_at.day != entry.entry_at.day
                        "#{entry.entry_at.strftime("%H:%M %p")}\r\n\r\n\r\n\r\n#{entry.entry_at.strftime("%a %d")}\r\n"
                    else
                        "#{entry.entry_at.strftime("%H:%M %p")}"
                    end
                end
                t.add_column("SPAN") do |entry|
                    "#{((entry.entry_at - entry.last_entry.entry_at) / 60 / 60).round(2)} hrs"
                end
                t.add_column("DEPTH") { |entry| "#{number_with_delimiter(entry.depth, :delimiter => ',')}" }
                t.add_column("DELTA") do |entry|
                    "(#{entry.depth - entry.last_entry.depth})"
                end
                t.add_column("ACTIVITY") { |entry| "#{DrillingLogEntry.activity_code_string(entry.activity_code)}" }
                t.add_column("COMMENT") { |entry| "#{entry.comment}" }
                t.add_column("BHA") { |entry| "#{!entry.bha.blank? ? entry.bha.name.split(" ")[0] : ''}" }
            end

            index = index + 1
        end
    end

    def range_span min, max
        if min != max
            "#{min} - #{max}"
        else
            "#{min}"
        end
    end

    def fill_survey job, entries, r
        r.add_field "JOB_NAME", job.field.name + ' - ' + job.well.name
        r.add_field "JOB_NUMBER", 'Job # ' + (job.job_number || '-')
        r.add_field "RIG", 'Rig ' + (job.well.rig.present? ? job.well.rig.name : '-')
        r.add_field "CLIENT", job.company.name

        if false
            new_entries = []
            entries.each do |e|
                e.instance_eval do
                    def comment_line
                        instance_variable_get("@comment_line")
                    end

                    def comment_line=(val)
                        instance_variable_set("@comment_line", val)
                    end
                end

                e.comment_line = false

                if !e.comment.blank?
                    new_sp = e.clone
                    new_sp.comment_line = true
                    new_entries << e
                end

                new_entries << e
            end
        end

        r.add_table("TABLE", entries, :header => false) do |t|
            t.add_column("DEPTH") do |entry|
                "#{number_with_delimiter(entry.measured_depth.round(2), :delimiter => ',')}"
            end
            t.add_column("INC") do |entry|
                "#{entry.inclination}"
            end
            t.add_column("AZI") do |entry|
                "#{entry.azimuth}"
            end
            t.add_column("TVD") { |entry| "#{number_with_delimiter(entry.true_vertical_depth.round(2), :delimiter => ',')}" }

            t.add_column("VSECT") do |entry|
                "#{entry.vertical_section.round(2)}"
            end
            t.add_column("NS") { |entry| "#{entry.north_south.round(2)}" }
            t.add_column("EW") { |entry| "#{entry.east_west.round(2)}" }
            t.add_column("DLS") { |entry| "#{entry.dog_leg_severity.present? ? entry.dog_leg_severity.round(2) : '-'}" }
        end
    end


    def fill_railroad job, well_plan, entries, r
        company = job.company
        r.add_field "ADDRESS_1", company.address_line_1 + ' ' + company.address_line_2
        r.add_field "ADDRESS_2", "#{company.city}, #{company.state} #{company.postal_code}"
        r.add_field "TODAY", Date.today.strftime("%B %d, %Y")
        r.add_field "NAME", company.railroad_signer
        r.add_field "TITLE", company.railroad_signer_title
        r.add_field "COMPANY", company.name
        r.add_field "CLIENT", job.client.name

        if !job.company.test_company
            image_path = "#{Rails.root}/tmp/#{company.id}.png"
            if !File.exist?(image_path)
                s3 = AWS::S3.new
                File.open(image_path, 'wb') do |f|
                    f.write(s3.buckets["elephant-public"].objects["images/#{company.id}.png"].read)
                end
            end
            r.add_image "LOGO", image_path
        end

        r.add_field "WELL_NAME", job.well.name

        if entries.present? && entries.any?
            hours = (entries.last.created_at - entries.first.created_at).to_f / 60.0 / 60.0
            if hours <= 24
                r.add_field "DATE", Date.today.strftime("%B %d, %Y")
            else
                r.add_field "DATE", "#{entries.first.created_at.strftime("%B %d, %Y")} - #{entries.last.created_at.strftime("%B %d, %Y")}"
            end

            r.add_field "START", entries.first.measured_depth
            r.add_field "END", entries.last.measured_depth
        else
            r.add_field "DATE", Date.today.strftime("%B %d, %Y")
            r.add_field "START", 0
            r.add_field "END", 0
        end
    end

    def fill_railroad_certification job, drilling_log, well_plan, survey, entries, r
        company = drilling_log.company
        r.add_field "ADDRESS_1", company.address_line_1 + ' ' + company.address_line_2
        r.add_field "ADDRESS_2", "#{company.city}, #{company.state} #{company.postal_code}"
        r.add_field "TODAY", Date.today.strftime("%B %d, %Y")
        r.add_field "NAME", company.railroad_signer
        r.add_field "TITLE", company.railroad_signer_title
        r.add_field "COMPANY", company.name
        r.add_field "CLIENT", job.client.name
        r.add_field "OP_NO", company.operator_number
        r.add_field "DATE", Date.today.strftime("%B %d, %Y")

        if !job.company.test_company
            image_path = "#{Rails.root}/tmp/#{company.id}.png"
            if !File.exist?(image_path)
                s3 = AWS::S3.new
                File.open(image_path, 'wb') do |f|
                    f.write(s3.buckets["elephant-public"].objects["images/#{company.id}.png"].read)
                end
            end
            r.add_image "LOGO", image_path
        end

        if job.present?
            jobs_sql = Survey.includes(:job).where("jobs.well_id = ?", job.well_id).select("jobs.id").to_sql
            users = JobMembership.includes(:job, :user).where("job_memberships.job_id IN (#{jobs_sql})").where("job_memberships.job_role_id = ?", JobMembership::FIELD)
            if users.any?
                r.add_field "NAMES", users.collect { |jm| jm.user.present? ? jm.user.name : '' }.to_sentence
            else
                r.add_field "NAMES", "-"
            end
        else
            r.add_field "NAMES", "-"
        end

        r.add_field "JOB_NUMBER", job.job_number.present? ? job.job_number : '-'
        r.add_field "API_NUMBER", job.api_number.present? ? job.api_number : '-'
        r.add_field "WELL_NAME", job.well.name
        r.add_field "COUNTY", "#{job.field.county}, #{job.field.state.name}"

        if survey.present? && entries.present? && entries.any?
            type = drilling_log.drilling_log_entries.where("drilling_log_entries.mwd_type IS NOT NULL").last
            r.add_field "JOB_TYPE", type.present? && type.mwd_type == 1 ? "Electromagnetic" : "Pulse"
            r.add_field "VS_AZIMUTH", "#{well_plan.present? ? well_plan.vertical_section_azimuth : '-'}"
            r.add_field "CORRECTION", "#{survey.total_correction}"
            r.add_field "NORTH_TYPE", survey.north_type == Survey::GRID ? "GRID" : (survey.north_type == Survey::TRUE ? "TRUE" : "MAGNETIC")

            tie_in = entries.first
            r.add_field "TIE_IN_MD", "#{tie_in.measured_depth}"
            r.add_field "TIE_IN_TVD", "#{tie_in.true_vertical_depth}"
            r.add_field "TIE_IN_INC", "#{tie_in.inclination}"
            r.add_field "TIE_IN_AZI", "#{tie_in.azimuth}"
            r.add_field "TIE_IN_NS", "#{tie_in.north_south}"
            r.add_field "TIE_IN_EW", "#{tie_in.east_west}"

            first = entries[1]
            if first.present?
                r.add_field "D1", "#{first.measured_depth}"
                r.add_field "INC1", "#{first.inclination}"
                r.add_field "AZI1", "#{first.azimuth}"
                r.add_field "DATE1", "#{first.created_at.strftime("%m/%d/%Y")}"
            else
                r.add_field "D1", "0.0"
                r.add_field "INC1", "0.0"
                r.add_field "AZI1", "0.0"
                r.add_field "DATE1", ""
            end

            last = entries.last
            r.add_field "D2", "#{last.measured_depth}"
            r.add_field "INC2", "#{last.inclination}"
            r.add_field "AZI2", "#{last.azimuth}"
            r.add_field "DATE2", "#{last.created_at.strftime("%m/%d/%Y")}"

            bha = drilling_log.drilling_log_entries.where("drilling_log_entries.bha_id IS NOT NULL").last
            r.add_field "D3", "#{last.measured_depth + (bha.present? && bha.bha.present? && bha.bha.bit_to_sensor.present? ? bha.bha.bit_to_sensor : 0.0)}"
            r.add_field "INC3", "#{last.inclination}"
            r.add_field "AZI3", "#{last.azimuth}"
        end
    end

    def drilling_log_to_excel drilling_log
        p = Axlsx::Package.new
        wb = p.workbook

        wb.styles do |s|
            title_cell = s.add_style :bg_color => "FF", :fg_color => "5d5d5d", :b => true, :sz => 16, :alignment => {:horizontal => :center}
            title_cell2 = s.add_style :bg_color => "FF", :fg_color => "5d5d5d", :b => true, :sz => 12, :alignment => {:horizontal => :center}
            column_name_cell = s.add_style :bg_color => "f3f6fb", :fg_color => "5d5d5d", :sz => 12, :b => true, :alignment => {:horizontal => :left}, :border => {:style => :thin, :color => "00", :edges => [:top, :bottom]}

            cell1 = s.add_style :bg_color => "fafdff", :fg_color => "5d5d5d", :b => false, :sz => 12, :alignment => {:horizontal => :left}
            cell2 = s.add_style :bg_color => "f3f6fb", :fg_color => "5d5d5d", :b => false, :sz => 12, :alignment => {:horizontal => :left}
            cell1_bold = s.add_style :bg_color => "fafdff", :fg_color => "5d5d5d", :b => true, :sz => 12, :alignment => {:horizontal => :left}
            cell2_bold = s.add_style :bg_color => "f3f6fb", :fg_color => "5d5d5d", :b => true, :sz => 12, :alignment => {:horizontal => :left}

            date1 = s.add_style :bg_color => "fafdff", :fg_color => "5d5d5d", :b => false, :sz => 12, :alignment => {:horizontal => :left}, :format_code => "yyyy-mm-dd"
            date2 = s.add_style :bg_color => "f3f6fb", :fg_color => "5d5d5d", :b => false, :sz => 12, :alignment => {:horizontal => :left}, :format_code => "yyyy-mm-dd"

            margins = {:left => 1, :right => 1, :top => 1, :bottom => 1, :header => 0, :footer => 0}
            setup = {:fit_to_width => 1, :orientation => :portrait, :paper_width => "21cm", :paper_height => "29.7cm"}
            options = {:grid_lines => true, :headings => true, :horizontal_centered => true}

            wb.add_worksheet(:name => "Daily Activity", :page_margins => margins, :page_setup => setup, :print_options => options) do |sheet|
                sheet.add_row ['Daily Activity', '', '', '', ''], :style => title_cell
                sheet.add_row [drilling_log.job.field.name + ' | ' + drilling_log.job.well.name, '', '', '', ''], :style => title_cell
                sheet.add_row [drilling_log.job.well.rig.present? ? drilling_log.job.well.rig.name : '', '', '', '', ''], :style => title_cell
                sheet.add_row ['', '', '', '', ''], :style => title_cell


                columns = ['Date', 'Time', 'Depth', 'BHA #', 'Activity', 'Comments']
                DrillingLogEntry.attribute_names.each do |attribute_name|
                    if attribute_name != "id" && attribute_name != "company_id" && attribute_name != "document_id" && attribute_name != "job_id" && attribute_name != "user_id" && attribute_name != "user_name" && attribute_name != "entry_at" && attribute_name != "created_at" && attribute_name != "updated_at" && attribute_name != "activity_code" && attribute_name != "depth" && attribute_name != "comment" && attribute_name != "bha_id" && attribute_name != "usage_hours" && attribute_name != "drilling_log_id"
                        columns << attribute_name.humanize
                    end
                end
                sheet.add_row columns, :style => column_name_cell

                drilling_log.drilling_log_entries.includes(:bha).each_with_index do |dl, index|
                    cell = index % 2 == 0 ? cell1 : cell2
                    bold = index % 2 == 0 ? cell1_bold : cell2_bold
                    date = index % 2 == 0 ? date1 : date2

                    values = [dl.entry_at.strftime("%Y-%m-%d"), dl.entry_at.strftime("%k:%M"), dl.depth, dl.bha.present? ? dl.bha.name : '', get_activity_code_string(dl.activity_code), dl.comment]
                    DrillingLogEntry.attribute_names.each do |attribute_name|
                        if attribute_name != "id" && attribute_name != "company_id" && attribute_name != "document_id" && attribute_name != "job_id" && attribute_name != "user_id" && attribute_name != "user_name" && attribute_name != "entry_at" && attribute_name != "created_at" && attribute_name != "updated_at" && attribute_name != "activity_code" && attribute_name != "depth" && attribute_name != "comment" && attribute_name != "bha_id" && attribute_name != "usage_hours" && attribute_name != "drilling_log_id"
                            values << dl[attribute_name]
                        end
                    end
                    sheet.add_row values, :style => [date, bold, bold, cell, bold, cell]
                end

                sheet.column_widths 15, 10, 10, 8, 30, 45, 7

                sheet.merge_cells("A1:F1")
                sheet.merge_cells("A2:F2")
                sheet.merge_cells("A3:F3")
                sheet.merge_cells("A4:F4")

            end
        end

        p
    end

    def get_activity_code_string value
        case value
            when DrillingLogEntry::DRILLING
                "DRILLING"
            when DrillingLogEntry::SLIDING
                "SLIDING"
            when DrillingLogEntry::CIRCULATING
                "CIRCULATING"
            when DrillingLogEntry::CONNECTION_SURVEY
                "CONNECTION & SURVEY"
            when DrillingLogEntry::REAMING
                "REAMING"
            when DrillingLogEntry::CEMENTING
                "CEMENTING"
            when DrillingLogEntry::CHANGE_MUD
                "CHANGE MUD"
            when DrillingLogEntry::CHANGE_BHA
                "CHANGE BHA"
            when DrillingLogEntry::POOH
                "POOH"
            when DrillingLogEntry::SHORT_TRIP
                "SHORT TRIP"
            when DrillingLogEntry::TIH
                "TIH"
            when DrillingLogEntry::TIH_CIRCULATING
                "TIH CIRCULATING"
            when DrillingLogEntry::WIRELINE
                "WIRELINE"
            when DrillingLogEntry::WORK_PIPE
                "WORK PIPE"
            when DrillingLogEntry::BOP_DRILL
                "BOP DRILL"
            when DrillingLogEntry::MWD_SURVEY
                "MWD SURVEY"
            when DrillingLogEntry::LD_DP
                "L/D DP"
            when DrillingLogEntry::PU_DP
                "P/U DP"
            when DrillingLogEntry::DRILLING_CEMENT
                "DRILLING CEMENT"
            when DrillingLogEntry::LOGGING
                "LOGGING"
            when DrillingLogEntry::CONNECTION
                "CONNECTION"
            when DrillingLogEntry::JETTING
                "JETTING"

            when DrillingLogEntry::OTHER
                "UNDEFINED"
            when DrillingLogEntry::RIG_REPAIR
                "RIG REPAIR"
            when DrillingLogEntry::PIPE_STUCK
                "PIPE STUCK"
            when DrillingLogEntry::FISHING
                "FISHING"
            when DrillingLogEntry::RIG_SERVICE_INHOLE
                "RIG SERVICE INHOLE"
            when DrillingLogEntry::WAIT_ON_WEATHER
                "WAIT ON WEATHER"
            when DrillingLogEntry::TROUBLESHOOT_MWD
                "TROUBLESHOOT MWD"


            when DrillingLogEntry::NIPPLE_BOPS
                "NIPPLE U/D BOPS"
            when DrillingLogEntry::TEST_BOPS
                "TEST BOPS"
            when DrillingLogEntry::SURFACE_TEST_MWD
                "SURFACE TEST MWD"


            when DrillingLogEntry::STANDBY_OUTHOLE
                "STANDBY"
            when DrillingLogEntry::RIG_SERVICE_OUTHOLE
                "RIG SERVICE OUTHOLE"

        end
    end

end
