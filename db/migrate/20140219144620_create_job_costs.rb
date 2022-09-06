class CreateJobCosts < ActiveRecord::Migration
    def change
        create_table :job_costs do |t|
            t.integer :company_id
            t.integer :job_id
            t.integer :user_id
            t.decimal :quantity, :default => 0
            t.string :description
            t.integer :charge_type
            t.decimal :price, :default => 0.0
            t.datetime :charge_at

            t.timestamps
        end

        add_index :job_costs, :company_id
        add_index :job_costs, :job_id
    end
end
