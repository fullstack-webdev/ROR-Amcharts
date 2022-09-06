class ChangeProgramToProgramIdFromRigs < ActiveRecord::Migration
  def change
    rename_column :rigs, :program, :program_id
  end
end
