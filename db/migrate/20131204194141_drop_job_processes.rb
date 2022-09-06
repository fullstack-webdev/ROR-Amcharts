class DropJobProcesses < ActiveRecord::Migration
  def change
      drop_table :job_processes
  end
end
