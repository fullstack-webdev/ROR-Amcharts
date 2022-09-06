class ChangeSurveyPointsTypo < ActiveRecord::Migration
  def change
      remove_column :survey_points, :east_west_decimal
      add_column :survey_points, :east_west, :decimal
  end
end
