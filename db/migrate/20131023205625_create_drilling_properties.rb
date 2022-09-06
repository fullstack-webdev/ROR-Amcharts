class CreateDrillingProperties < ActiveRecord::Migration
    def change
        create_table :drilling_properties do |t|
            t.integer :company_id
            t.integer :user_id
            t.integer :document_id

            t.decimal :wob
            t.decimal :rot_wt
            t.decimal :pu_wt
            t.decimal :so_wt
            t.decimal :spp
            t.decimal :flow
            t.decimal :spm
            t.decimal :rot_rpm
            t.decimal :mot_rpm
            t.decimal :incl_in
            t.decimal :azm_in
            t.decimal :incl_out
            t.decimal :azm_out

            t.timestamps
        end

        add_index :drilling_properties, :document_id
    end
end
