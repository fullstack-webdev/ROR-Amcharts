class CreateWitsData < ActiveRecord::Migration
  def change
    create_table :wits_data, {:id => false, :force => true} do |t|
      t.integer :company_id
      t.integer :job_id
      t.datetime :entry_at
      t.float :hook_load
      t.float :rotary_torque
      t.float :rotary_rpm
      t.float :standpipe_pressure
      t.float :block_height
      t.float :bit_depth
      t.float :hole_depth
      t.float :weight_on_bit

      t.float :total_gas
      t.float :mud_flow_in
      t.float :mud_flow_out
      t.float :mud_temp_in
      t.float :mud_temp_out

      t.float :pump_spm_total
      t.float :gain_loss
      t.float :gamma_ray
      t.float :mud_volume
      t.float :strks_pump_1
      t.float :strks_pump_2
      t.float :strks_pump_3
      t.float :strks_total
      t.float :svy_azimuth
      t.float :svy_depth
      t.float :svy_inclination
      t.float :pump_spm_1
      t.float :pump_spm_2
      t.float :pump_spm_3
      t.float :pit_volume_1
      t.float :pit_volume_2
      t.float :pit_volume_3
      t.float :pit_volume_4
      t.float :pit_volume_5
      t.float :pit_volume_6
      t.float :pit_volume_7
      t.float :pit_volume_8

      t.timestamps
    end
  end
end
