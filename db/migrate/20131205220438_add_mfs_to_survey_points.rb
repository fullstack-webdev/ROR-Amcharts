class AddMfsToSurveyPoints < ActiveRecord::Migration
  def change
    add_column :survey_points, :magnetic_field_strength, :decimal
    add_column :survey_points, :magnetic_dip_angle, :decimal
    add_column :survey_points, :gravity_total, :decimal
  end
end
