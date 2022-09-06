class DropCrews < ActiveRecord::Migration
    def change
        drop_table :crews
        remove_index(:crew_memberships, :name => 'index_crew_memberships_on_user_id_and_crew_id')
        rename_table :crew_memberships, :rig_memberships

        add_column :rig_memberships, :rig_id, :integer
        add_index :rig_memberships, :rig_id
        add_index :rig_memberships, [:user_id, :rig_id], unique: true
    end
end
