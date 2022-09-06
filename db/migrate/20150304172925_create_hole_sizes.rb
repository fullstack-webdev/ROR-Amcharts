class CreateHoleSizes < ActiveRecord::Migration
  def change
    create_table :hole_sizes do |t|
      t.belongs_to :company
      t.belongs_to :job
      t.float :diameter
      t.float :depth
      t.datetime :entry_at
      t.timestamps
    end

    add_index :hole_sizes, :company_id
    add_index :hole_sizes, :job_id
    add_index :hole_sizes, :entry_at
  end
end
