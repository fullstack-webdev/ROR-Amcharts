module JobLogHelper
    require 'axlsx'

    def logs_to_excel entries, document
        p = Axlsx::Package.new
        wb = p.workbook

        wb.styles do |s|
            title_cell = s.add_style :bg_color => "FF", :fg_color => "5d5d5d", :b => true, :sz => 18, :alignment => {:horizontal => :center}
            title_cell2 = s.add_style :bg_color => "FF", :fg_color => "5d5d5d", :b => true, :sz => 14, :alignment => {:horizontal => :center}
            column_name_cell = s.add_style :bg_color => "f3f6fb", :fg_color => "5d5d5d", :sz => 15, :alignment => {:horizontal => :left}, :border => { :style => :thin, :color =>"00", :edges => [:top, :bottom] }

            cell1 = s.add_style :bg_color => "fafdff", :fg_color => "5d5d5d", :b => false, :sz => 13
            cell2 = s.add_style :bg_color => "f3f6fb", :fg_color => "5d5d5d", :b => false, :sz => 13


            margins = {:left => 1, :right => 1, :top => 1, :bottom => 1, :header => 0, :footer => 0}
            setup = {:fit_to_width => 1, :orientation => :portrait, :paper_width => "21cm", :paper_height => "29.7cm"}
            options = {:grid_lines => true, :headings => true, :horizontal_centered => true}

            wb.add_worksheet(:name => "Job Log", :page_margins => margins, :page_setup => setup, :print_options => options) do |sheet|
                sheet.add_row ['', '', 'Job Log', ''], :style => title_cell
                sheet.add_row ['', '', document.job.field.name + " | " + document.job.well.name, ''], :style => title_cell2
                sheet.add_row ['', '', '', ''], :style => title_cell
                sheet.add_row ['Date', 'Time', 'Comment/Description', 'User'], :style => column_name_cell

                entries.each_with_index do |entry, index|
                    sheet.add_row [entry.entry_at.strftime("%a %m/%d/%Y"), entry.entry_at.strftime("%l:%M %p"), entry.comment, entry.user.present? ? entry.user.name : entry.user_name], :style => index % 2 == 0 ? cell1 : cell2
                end

                sheet.column_widths 14, 10, 100, 15

            end
        end

        p
    end
end
