class RemoveJobIdFromWitsmlServers < ActiveRecord::Migration
  def up
    remove_column :witsml_servers, :job_id
  end

  def down
    add_column :witsml_servers, :job_id, :integer
  end
end
