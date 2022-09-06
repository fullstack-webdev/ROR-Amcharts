class CreateLwdLogs < ActiveRecord::Migration
  def change
    create_table :lwd_logs do |t|
      t.integer :company_id
      t.integer :job_id

      t.float :depth
      t.float :GRAPI
      t.float :RHOB
      t.float :NPHI
      t.float :DTCO
      t.float :DTSM
      t.float :HDMI
      t.float :HDMX
      t.float :pore_pressure
      t.float :UCS
      t.float :YM
      t.float :LOT
      t.float :Minifrac

      t.timestamps
    end

    add_index :lwd_logs, :company_id
    add_index :lwd_logs, :job_id
  end
end
