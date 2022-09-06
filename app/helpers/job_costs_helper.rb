module JobCostsHelper
    require 'axlsx'
    include ActionView::Helpers::NumberHelper

    def job_costs_to_excel job
        p = Axlsx::Package.new
        wb = p.workbook

        wb.styles do |s|
            title_cell = s.add_style :bg_color => "FF", :fg_color => "5d5d5d", :b => true, :sz => 18, :alignment => {:horizontal => :center}
            column_name_cell = s.add_style :bg_color => "f3f6fb", :fg_color => "5d5d5d", :sz => 14, :b => true, :alignment => {:horizontal => :left}, :border => {:style => :thin, :color => "00", :edges => [:top, :bottom]}

            cell1 = s.add_style :bg_color => "fafdff", :fg_color => "5d5d5d", :b => false, :sz => 13, :alignment => {:horizontal => :left}
            cell2 = s.add_style :bg_color => "f3f6fb", :fg_color => "5d5d5d", :b => false, :sz => 13, :alignment => {:horizontal => :left}
            cell1_bold = s.add_style :bg_color => "fafdff", :fg_color => "5d5d5d", :b => true, :sz => 13, :alignment => {:horizontal => :left}, :num_fmt => 5
            cell2_bold = s.add_style :bg_color => "f3f6fb", :fg_color => "5d5d5d", :b => true, :sz => 13, :alignment => {:horizontal => :left}, :num_fmt => 5
            cell1_money = s.add_style :bg_color => "fafdff", :fg_color => "5d5d5d", :b => false, :sz => 13, :alignment => {:horizontal => :left}, :num_fmt => 5
            cell2_money  = s.add_style :bg_color => "f3f6fb", :fg_color => "5d5d5d", :b => false, :sz => 13, :alignment => {:horizontal => :left}, :num_fmt => 5


            margins = {:left => 1, :right => 1, :top => 1, :bottom => 1, :header => 0, :footer => 0}
            setup = {:fit_to_width => 1, :orientation => :portrait, :paper_width => "21cm", :paper_height => "29.7cm"}
            options = {:grid_lines => true, :headings => true, :horizontal_centered => true}

            wb.add_worksheet(:name => "Costs", :page_margins => margins, :page_setup => setup, :print_options => options) do |sheet|
                sheet.add_row ['Costs', '', '', '', '', ''], :style => title_cell
                sheet.add_row [job.name, '', '', '', '', ''], :style => title_cell
                sheet.add_row ['', '', '', '', '', ''], :style => title_cell


                sheet.add_row ['Date', 'Type', 'Quantity', 'Description', 'Price', 'Item Price'], :style => column_name_cell

                job.job_costs.each_with_index do |jc, index|
                    sheet.add_row [jc.charge_at.in_time_zone.strftime("%m/%d/%Y"),
                                   JobCost.charge_type_string(jc.charge_type),
                                   jc.quantity.to_f == jc.quantity.to_i ? jc.quantity.to_i : jc.quantity.to_f,
                                   jc.description,
                                   jc.price * jc.quantity.to_f,
                                   jc.quantity.to_f != 1.0 ? jc.price : jc.price], :style => index % 2 == 0 ? [cell1, cell1, cell1, cell1, cell1_bold, cell1_money] : [cell2, cell2, cell2, cell2, cell2_bold, cell2_money], :types => [:string, :string, :integer, :string, :float, :float]
                end



                sheet.column_widths 20, 20, 20, 66, 20, 20

                sheet.merge_cells("A1:F1")
                sheet.merge_cells("A2:F2")

            end
        end

        p
    end

end
