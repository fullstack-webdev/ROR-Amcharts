class CreateEventWarningTypes < ActiveRecord::Migration
  def change
    create_table :event_warning_types do |t|
      t.string :name
      t.string :severity
      t.string :category
      t.text :description
      t.text :resolution
      t.timestamps
    end
  end
end
