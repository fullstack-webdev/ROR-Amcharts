class CreateBhaItems < ActiveRecord::Migration
    def change
        create_table :bha_items do |t|
            t.integer :company_id
            t.integer :bha_id
            t.integer :tool_id
            t.string :tool_type
            t.decimal :inner_diameter
            t.decimal :outer_diameter
            t.decimal :length

            t.timestamps
        end

        add_index :bha_items, :bha_id
        add_index :bha_items, :company_id

        remove_column :bhas, :inner_diameter
        remove_column :bhas, :outer_diameter
        remove_column :bhas, :length
        remove_column :bhas, :configuration
    end
end
