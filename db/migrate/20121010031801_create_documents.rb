class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.integer :job_template_id
      t.integer :job_id
      t.string :category
      t.string :name
      t.string :url
      t.string :status
      t.boolean :template, default: false

      t.timestamps
    end

    add_index :documents, :job_template_id
    add_index :documents, :job_id
  end
end
