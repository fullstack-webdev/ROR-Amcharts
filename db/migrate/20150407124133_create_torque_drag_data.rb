class CreateTorqueDragData < ActiveRecord::Migration
  def change
    create_table :torque_drag_data do |t|
      t.belongs_to :job
      t.belongs_to :company
      t.datetime :entry_at
      t.string :file_name

      t.timestamps
    end
    add_index :torque_drag_data, :job_id
    add_index :torque_drag_data, :company_id
  end
end
