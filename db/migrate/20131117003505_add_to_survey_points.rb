class AddToSurveyPoints < ActiveRecord::Migration
  def change
      add_column :survey_points, :course_length, :decimal
      add_column :survey_points, :dog_leg_severity, :decimal
      add_column :survey_points, :closure_distance, :decimal
      add_column :survey_points, :closure_angle, :decimal
  end
end
