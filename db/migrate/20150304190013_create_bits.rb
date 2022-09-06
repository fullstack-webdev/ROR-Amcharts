class CreateBits < ActiveRecord::Migration
  def change
    create_table :bits do |t|
      t.belongs_to :job
      t.belongs_to :company
      t.float :size
      t.string :make
      t.string :jets
      t.float :tfa
      t.float :jets_velocity
      t.float :jet_impact_force
      t.float :hhsi
      t.string :serial_no
      t.datetime :entry_at
      t.timestamps
    end

    add_index :bits, :job_id
    add_index :bits, :company_id
    add_index :bits, :entry_at
  end
end
