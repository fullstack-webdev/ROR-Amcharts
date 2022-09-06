class AddMasterBhaIdToBhas < ActiveRecord::Migration
    def change
        add_column :bhas, :master_bha_id, :integer
    end
end
