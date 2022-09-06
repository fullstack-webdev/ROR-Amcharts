class AddUserToSurveyPoints < ActiveRecord::Migration
  def change
    add_column :survey_points, :user_id, :integer
    add_column :survey_points, :user_name, :string
  end
end
