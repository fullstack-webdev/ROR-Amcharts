class CsvImport < ActiveRecord::Migration
  def up
    create_table :csv_mappings do |t|
      t.string :column_from
      t.string :column_to
    end

    create_table :import_history do |t|
      t.integer :job_id
      t.string :filename

      t.timestamp
    end
  end

  def down
    drop_table :csv_mappings
    drop_table :import_history
  end
end
