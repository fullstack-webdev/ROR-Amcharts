class CreatePrograms < ActiveRecord::Migration
  def change
    create_table :programs do |t|
      t.string :name
      t.timestamps
    end

    create_table :programs_wells, id: false do |t|
      t.belongs_to :program, index: true
      t.belongs_to :well, index: true
    end
  end
end
