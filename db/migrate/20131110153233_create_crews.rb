class CreateCrews < ActiveRecord::Migration
    def change
        create_table :crews do |t|
            t.integer :company_id
            t.integer :district_id
            t.integer :current_job
            t.integer :crew_memberships_count, :default => 0
            t.string :name

            t.timestamps
        end

        add_index :crews, :district_id
    end
end
