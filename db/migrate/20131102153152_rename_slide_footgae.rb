class RenameSlideFootgae < ActiveRecord::Migration
    def change
        rename_column :drilling_logs, :slide_footgae, :slide_footage
    end
end
