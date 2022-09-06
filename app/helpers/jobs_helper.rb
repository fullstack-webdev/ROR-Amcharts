# ecoding: utf-8

module JobsHelper
    require 'csv'
    require 'roo'
    require 'date'

    def import job, file_name

        spreadsheet = nil
        case File.extname(file_name)
            when ".csv"
                spreadsheet = Roo::Spreadsheet.open(file_name)
            when ".xls"
                spreadsheet = Roo::Spreadsheet.open(file_name)
            when ".xlsx"
                spreadsheet = Roo::Spreadsheet.open(file_name)
        end

        puts "Spreadsheets"
        puts spreadsheet.sheets.count
        puts spreadsheet.sheets
        #sheet = spreadsheet.sheet(5)


        (1..spreadsheet.sheets.count).each do |s|
            sheet = spreadsheet.sheet(s)
            begin
                if sheet != nil
                    cell = sheet.cell(8, 24)
                    if cell != nil && cell.instance_of?(Date)
                        date = Date.strptime(cell.to_s, '%Y-%m-%d')
                        if date.present?
                            puts cell.to_s
                            save_costs job, sheet, date
                            save_comments job, sheet, date
                        end
                    end
                end
            rescue => e
                puts e.message
            end
        end


    end


    def save_costs job, sheet, date
        total_cost = 0.0
        if sheet.cell(9, 21).to_s == "Item"
            (10..34).each do |r|
                item_name = sheet.cell(r, 21).to_s
                item_count = sheet.cell(r, 28).to_i
                unit_cost = sheet.cell(r, 30).to_f

                if item_count > 0
                    total_cost += (unit_cost * item_count)

                    job_cost = JobCost.new
                    job_cost.job = job
                    job_cost.company = job.company
                    job_cost.charge_at = date.to_date
                    job_cost.charge_type = JobCost::ITEM
                    job_cost.description = item_name
                    job_cost.price = unit_cost
                    job_cost.quantity = item_count
                    job_cost.imported = true
                    job_cost.save
                end

            end

        end

        puts "total cost #{total_cost}"
    end

    def save_comments job, sheet, date
        if sheet.cell(9, 1).to_s == "From"
            (10..36).each do |r|
                start_time = Time.at(sheet.cell(r, 1).to_i).utc
                end_time = Time.at(sheet.cell(r, 3).to_i).utc
                #start_time = Time.strptime(sheet.cell(r, 1).to_s.downcase, '%H:%M:%S %P')
                #end_time = Time.strptime(sheet.cell(r, 3).to_s.downcase, '%H:%M:%S %P')
                hours = sheet.cell(r, 5).to_f
                comment = sheet.cell(r, 7).to_s


                if !comment.empty?

                    puts "start " + start_time.to_s

                    drilling_log_entry = DrillingLogEntry.new
                    drilling_log_entry.job = job
                    drilling_log_entry.company = job.company
                    drilling_log_entry.entry_at = Time.new(date.year, date.month, date.day, start_time.hour, start_time.min, 0).in_time_zone(Time.zone)
                    if end_time.hour == 0 && end_time.min == 0
                        drilling_log_entry.end_time = Time.new(date.year, date.month, date.day, 23, 59, 59).in_time_zone(Time.zone)
                    else
                        drilling_log_entry.end_time = Time.new(date.year, date.month, date.day, end_time.hour, end_time.min, 0).in_time_zone(Time.zone)
                    end
                    drilling_log_entry.hours = hours
                    drilling_log_entry.comment = comment
                    drilling_log_entry.additional = false
                    drilling_log_entry.save

                    puts comment
                end

            end

        end

        additional_comment = sheet.cell(59, 1).to_s
        if additional_comment.length > 10
            drilling_log_entry = DrillingLogEntry.new
            drilling_log_entry.job = job
            drilling_log_entry.company = job.company
            drilling_log_entry.entry_at = Time.new(date.year, date.month, date.day, 0, 0, 0).in_time_zone(Time.zone)
            drilling_log_entry.end_time = Time.new(date.year, date.month, date.day, 0, 0, 0).in_time_zone(Time.zone)
            drilling_log_entry.comment = additional_comment
            drilling_log_entry.additional = true
            drilling_log_entry.save
        end
    end


    def show_warning_date d
        if d.to_date == Date.today
            d.strftime('%l:%M%P')
        elsif d.strftime('%Y') == Date.today.strftime('%Y')
            d.strftime('%b %e %l:%M%P')
        else
            d.strftime('%b %e %Y %l:%M%P')
        end
    end

    def cache_key_for_well well
        job = well.jobs.try(:first)
        if job.present?
            WitsRecord.table_name = "wits_records#{job.id}"
            max_updated_at = WitsRecord.maximum(:updated_at).try(:utc).try(:to_s, :number)
            count = WitsRecord.count(:all)
            "jobs/#{job.id}-#{count}-#{max_updated_at}"
        end
    end
end
