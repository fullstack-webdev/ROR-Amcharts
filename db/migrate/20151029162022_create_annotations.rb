class CreateAnnotations < ActiveRecord::Migration
    def change
        create_table :annotations do |t|
            t.integer :company_id
            t.integer :job_id
            t.integer :user_id
            t.datetime :start_time
            t.datetime :end_time
            t.decimal :start_depth
            t.decimal :end_depth
            t.integer :event_warning_id
            t.integer :company_feature_id
            t.string :title

            t.timestamps
        end

        add_index :annotations, :job_id
        add_index :annotations, :company_id
    end
end
