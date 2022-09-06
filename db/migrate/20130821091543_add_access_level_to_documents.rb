class AddAccessLevelToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :access_level, :integer, :default => 0
  end
end
