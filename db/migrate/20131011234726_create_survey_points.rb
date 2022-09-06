class CreateSurveyPoints < ActiveRecord::Migration
    def change
        create_table :survey_points do |t|
            t.integer :company_id
            t.integer :survey_id
            t.decimal :measured_depth
            t.decimal :inclination
            t.decimal :azimuth
            t.boolean :tie_on
            t.decimal :true_vertical_depth
            t.decimal :north_south
            t.string :east_west_decimal

            t.timestamps
        end

        add_index :survey_points, :survey_id
    end
end
