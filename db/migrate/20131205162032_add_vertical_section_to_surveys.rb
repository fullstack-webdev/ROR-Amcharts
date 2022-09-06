class AddVerticalSectionToSurveys < ActiveRecord::Migration
  def change
    add_column :surveys, :vertical_section_azimuth, :decimal
  end
end
