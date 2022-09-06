class ChangeColumnInWitsGactivity < ActiveRecord::Migration
  def change
    remove_column :wits_gactivities, :activity
    add_column :wits_gactivities, :activity, :integer
  end

end
