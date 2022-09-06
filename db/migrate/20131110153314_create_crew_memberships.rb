class CreateCrewMemberships < ActiveRecord::Migration
    def change
        create_table :crew_memberships do |t|
            t.integer :company_id
            t.integer :crew_id
            t.integer :user_id
            t.string :user_name

            t.timestamps
        end

        add_index :crew_memberships, :user_id
        add_index :crew_memberships, :crew_id
        add_index :crew_memberships, [:user_id, :crew_id], unique: true
    end
end
