class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.integer :company_id
      t.integer :user_id
      t.integer :activity_type
      t.integer :target_id
      t.string :target_type

      t.timestamps
    end

    add_index :activities, [:target_id, :target_type]
    add_index :activities, :company_id
    add_index :activities, :user_id
  end
end
