class DropCrewsIndex < ActiveRecord::Migration
  def change
      remove_index(:rig_memberships, :name => 'index_crew_memberships_on_crew_id')
  end
end
