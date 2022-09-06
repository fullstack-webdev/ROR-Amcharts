class CreateAlerts < ActiveRecord::Migration
    def change
        create_table :alerts do |t|
            t.integer :company_id
            t.integer :user_id
            t.integer :alert_type
            t.integer :target_id
            t.string :target_type
            t.integer :job_id
            t.integer :created_by

            t.timestamps
        end

        add_index :alerts, [:target_id, :target_type]
        add_index :alerts, :company_id
        add_index :alerts, :user_id
        add_index :alerts, :job_id
        add_index :alerts, :created_by
    end
end
