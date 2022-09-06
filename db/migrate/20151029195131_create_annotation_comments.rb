class CreateAnnotationComments < ActiveRecord::Migration
    def change
        create_table :annotation_comments do |t|
            t.integer :company_id
            t.integer :annotation_id
            t.integer :user_id
            t.string :text

            t.timestamps
        end

        add_index :annotation_comments, :company_id
    end
end
