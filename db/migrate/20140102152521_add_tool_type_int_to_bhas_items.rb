class AddToolTypeIntToBhasItems < ActiveRecord::Migration
    def change
        remove_column :bha_items, :tool_type
        add_column :bha_items, :asset_type, :integer
    end
end
