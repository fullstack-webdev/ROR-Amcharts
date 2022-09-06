module JobsExportHelper

    require 'axlsx'

    def to_excel jobs
        p = Axlsx::Package.new
        wb = p.workbook

        wb.add_worksheet(:name => "Job Search") do |sheet|
            #sheet.add_row ['Month', 'Year', 'Type', 'Sales', 'Region']
            #30.times { sheet.add_row [month, year, type, sales, region] }


            # exclude rating, failure count, people count - include summary data
            columns = Job.new.attributes.select { |j| include_column(j)  }.map { |j| Job.human_attribute_name(j[0]) }
            columns << "Rig"
            columns << "Data"
            sheet.add_row columns

            jobs.each do |job|
                data = job.attributes.select { |j| include_column(j)  }.map { |j| get_expanded_name job, j }
                data << (job.well.rig.present? ? job.well.rig.name : "")
                data << job.dynamic_fields.select { |df| !df.template? && df.priority? }.map { |df| df.name + ": " + (df.value.present? ? df.value : "-") }.join(", ")
                sheet.add_row data
            end
        end

        p
    end

    def get_expanded_name job, entry
         case entry[0]
             when "well_id"
                 return job.well.name
             when "field_id"
                 return job.field.name
             when "district_id"
                 return job.district.present? ? job.district.name : ""
             when "company_id"
                 return job.company.name
             when "status"
                 return job.status_string
         end

         entry[1]
    end

    def include_column property
        puts property + " ................."
        case property.to_s
            when "end_date", "updated_at", "company_id", "rating", "failures_count", "job_memberships_count"
                return false
        end

        return true
    end
end