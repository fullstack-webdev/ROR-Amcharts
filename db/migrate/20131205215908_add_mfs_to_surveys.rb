class AddMfsToSurveys < ActiveRecord::Migration
  def change
    add_column :surveys, :magnetic_field_strength, :decimal
    add_column :surveys, :magnetic_dip_angle, :decimal
    add_column :surveys, :gravity_total, :decimal
  end
end
