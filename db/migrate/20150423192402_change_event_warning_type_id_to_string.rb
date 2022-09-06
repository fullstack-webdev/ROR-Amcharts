class ChangeEventWarningTypeIdToString < ActiveRecord::Migration
  def up
    change_column :event_warnings, :event_warning_type_id, :string
  end

  def down
    change_column :event_warnings, :event_warning_type_id, :integer
  end
end
