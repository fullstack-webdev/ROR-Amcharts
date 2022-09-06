class CreateEventWarnings < ActiveRecord::Migration
  def change
    create_table :event_warnings do |t|
      t.integer :warning_type
      t.datetime :opened_at
      t.datetime :closed_at
      t.belongs_to :rig
      t.belongs_to :well

      t.timestamps
    end
    add_index :event_warnings, :rig_id
    add_index :event_warnings, :well_id
  end
end
