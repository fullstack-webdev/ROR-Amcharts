class AddCommentToSurveyPoint < ActiveRecord::Migration
  def change
    add_column :survey_points, :comment, :string
    add_column :survey_points, :vertical_section, :decimal
  end
end
