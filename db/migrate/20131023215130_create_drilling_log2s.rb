class CreateDrillingLog2s < ActiveRecord::Migration
    def change
        create_table :drilling_logs do |t|
            t.integer :company_id
            t.integer :document_id
            t.integer :job_id
            t.decimal :rop
            t.decimal :total_drilled
            t.decimal :below_rotary
            t.decimal :slide_rop
            t.decimal :slide_footgae
            t.decimal :slide_hours
            t.decimal :rotate_rop
            t.decimal :rotate_footage
            t.decimal :rotate_hours
            t.decimal :circulation_hours
            t.decimal :ream_hours
            t.decimal :rotary_hours_pct
            t.decimal :slide_hours_pct
            t.decimal :rotary_footage_pct
            t.decimal :slide_footage_pct

            t.timestamps
        end
    end
end
