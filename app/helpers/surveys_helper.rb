module SurveysHelper

    include ActionView::Helpers::NumberHelper

    def survey_to_excel well_plan, survey
        p = Axlsx::Package.new
        wb = p.workbook

        wb.styles do |s|
            title_cell = s.add_style :bg_color => "FF", :fg_color => "5d5d5d", :b => true, :sz => 16, :alignment => {:horizontal => :center}
            title_cell2 = s.add_style :bg_color => "FF", :fg_color => "5d5d5d", :b => true, :sz => 12, :alignment => {:horizontal => :center}
            title_cell3 = s.add_style :bg_color => "FF", :fg_color => "5d5d5d", :b => false, :sz => 12, :alignment => {:horizontal => :left}
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

            calculated_points = survey.no_well_plan || well_plan.nil? ? [] : well_plan.survey_points
            calculated_points_survey = survey.calculated_points(survey.no_well_plan || well_plan.nil? ? 0 : well_plan.vertical_section_azimuth)


            wb.add_worksheet(:name => "Survey", :page_margins => margins, :page_setup => setup, :print_options => options) do |sheet|
                sheet.add_row ['Survey', '', '', '', ''], :style => title_cell
                sheet.add_row [survey.job.name, '', '', '', ''], :style => title_cell2
                sheet.add_row ['', '', '', '', ''], :style => title_cell
                if calculated_points_survey.any?
                    sheet.add_row ["Total Correction: #{survey.total_correction} \t\t\t North Type: #{survey.north_type == Survey::GRID ? "Grid" : (survey.north_type == Survey::TRUE ? "True" : "Magnetic")} \t\t\t V Sec Azimuth: #{well_plan.present? && well_plan.vertical_section_azimuth.present? ? well_plan.vertical_section_azimuth : '-'}", '', "", '', ''], :style => title_cell2
                    sheet.add_row ["Mag Field Strength: #{survey.magnetic_field_strength.present? ? survey.magnetic_field_strength.round(4) : 0.0} \t\t\t Mag Dip Angle: #{survey.magnetic_dip_angle.present? ? survey.magnetic_dip_angle.round(4) : 0.0} \t\t\t Gravity: #{survey.gravity_total.present? ? survey.gravity_total.round(4) : 0.0}", '', "", '', ''], :style => title_cell2
                end
                sheet.add_row ['', '', '', '', ''], :style => title_cell


                sheet.add_row ['M. Depth', 'Inc', 'Azi', 'TVD', 'V Sect', '+N/S-', '+E/W-', 'DLS', 'MFS', 'MDA', 'Grav', 'Comment'], :style => column_name_cell

                calculated_points_survey.each_with_index do |point, index|
                    cell = index % 2 == 0 ? cell1 : cell2
                    bold = index % 2 == 0 ? cell1_bold : cell2_bold

                    sheet.add_row [point.measured_depth.round(2),
                                   point.inclination,
                                   point.azimuth,
                                   point.true_vertical_depth.round(2),
                                   point.vertical_section.round(2),
                                   point.north_south.round(2),
                                   point.east_west.round(2),
                                   point.dog_leg_severity.present? ? point.dog_leg_severity.round(2) : 0.0,
                                   point.magnetic_field_strength.present? ? point.magnetic_field_strength.round(4) : '-',
                                   point.magnetic_dip_angle.present? ? point.magnetic_dip_angle.round(4) : '-',
                                   point.gravity_total.present? ? point.gravity_total.round(4) : '-',
                                   point.comment], :style => [bold, bold, bold, cell, bold, cell, cell, cell, cell, cell, cell, cell]
                end

                sheet.column_widths 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10

                sheet.merge_cells("A1:L1")
                sheet.merge_cells("A2:L2")
                sheet.merge_cells("A3:L3")
                if calculated_points_survey.any?
                    sheet.merge_cells("A4:L4")
                    sheet.merge_cells("A5:L5")
                    sheet.merge_cells("A6:L6")
                end

            end
        end

        p
    end

end
