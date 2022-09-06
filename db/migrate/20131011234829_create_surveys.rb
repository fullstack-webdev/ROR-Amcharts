class CreateSurveys < ActiveRecord::Migration
    def change
        create_table :surveys do |t|
            t.integer :company_id
            t.integer :document_id
            t.integer :job_id
            t.integer :user_id
            t.boolean :plan
            t.string :name

            t.timestamps
        end

        add_index :surveys, :document_id
        add_index :surveys, :job_id
    end
end
