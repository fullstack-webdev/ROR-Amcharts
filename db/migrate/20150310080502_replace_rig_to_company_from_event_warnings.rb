class ReplaceRigToCompanyFromEventWarnings < ActiveRecord::Migration
  def change
    remove_index :event_warnings, :rig_id
    remove_column :event_warnings, :rig_id
    add_column :event_warnings, :company_id, :integer
    add_index :event_warnings, :company_id
  end
end
