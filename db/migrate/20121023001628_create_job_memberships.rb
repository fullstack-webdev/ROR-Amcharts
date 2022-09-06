class CreateJobMemberships < ActiveRecord::Migration
  def change
    create_table :job_memberships do |t|
      t.integer :user_id
      t.integer :job_id

      t.timestamps
    end

    add_index :job_memberships, :user_id
    add_index :job_memberships, :job_id
    add_index :job_memberships, [:user_id, :job_id], unique: true
  end
end
