class AddTypeToCrews < ActiveRecord::Migration
    def change
        add_column :crews, :rig_id, :integer
        add_column :crews, :shift_type, :integer

        add_index :crews, :rig_id
    end
end
