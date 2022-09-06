class CreateBhas < ActiveRecord::Migration
    def change
        create_table :bhas do |t|
            t.integer :company_id
            t.integer :job_id
            t.integer :document_id
            t.string :name
            t.string :configuration

            t.decimal :inner_diameter
            t.decimal :outer_diameter
            t.decimal :length

            t.timestamps
        end

        add_index :bhas, :document_id
        add_index :bhas, :company_id
    end
end
