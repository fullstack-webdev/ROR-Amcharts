class AddMetadataToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :metadata, :string
  end
end
