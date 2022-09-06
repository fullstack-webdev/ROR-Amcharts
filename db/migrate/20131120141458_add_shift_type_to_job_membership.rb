class AddShiftTypeToJobMembership < ActiveRecord::Migration
  def change
    add_column :job_memberships, :shift_type, :integer
  end
end
