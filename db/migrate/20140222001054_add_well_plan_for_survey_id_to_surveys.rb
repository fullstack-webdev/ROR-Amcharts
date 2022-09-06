class AddWellPlanForSurveyIdToSurveys < ActiveRecord::Migration
    def change
        add_column :surveys, :well_plan_for_survey_id, :integer
    end
end
