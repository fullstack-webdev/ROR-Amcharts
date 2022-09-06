class ReplaceWellToJobFromEventWarnings < ActiveRecord::Migration
  def change
    remove_index :event_warnings, :well_id
    remove_column :event_warnings, :well_id
    add_column :event_warnings, :job_id, :integer
    add_index :event_warnings, :job_id
  end

end
