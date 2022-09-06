class CreateFullActualTads < ActiveRecord::Migration
  def change
    create_table :full_actual_tads do |t|
      t.belongs_to :job
      t.belongs_to :company
      t.datetime :entry_at
      t.string :file_name

      t.timestamps
    end
    add_index :full_actual_tads, :job_id
    add_index :full_actual_tads, :company_id
  end
end
