class CreateFluids < ActiveRecord::Migration
  def change
    create_table :fluids do |t|
      t.string :type
      t.float :density
      t.float :funnel_viscosity
      t.float :filtrate
      t.float :ph
      t.float :mud_cake_thickness
      t.float :high_gravity_densities
      t.float :low_gravity_densities
      t.float :high_gravity_volume
      t.float :low_gravity_volume
      t.float :drilled_solids_volume
      t.float :rpm600
      t.float :rpm300
      t.float :rpm200
      t.float :rpm100
      t.float :rpm6
      t.float :rpm3
      t.float :seconds10
      t.float :minutes10
      t.float :water_volume
      t.float :oil_volume
      t.float :solid_volume
      t.float :methylene_blue
      t.float :drilling_fluid
      t.float :bentonite
      t.float :total_cl
      t.float :k_acetate
      t.float :potassium_bromide
      t.float :sodium_bromide
      t.float :calcium_bromide
      t.float :potassium_formate
      t.float :sodium_formate
      t.float :cesium_formate
      t.float :ammonium_chloride
      t.float :kci
      t.float :k2so4
      t.float :cacl2
      t.float :mgcl2
      t.float :brine_density
      t.datetime :entry_at
      t.belongs_to :job
      t.belongs_to :company
      t.timestamps
    end

    add_index :fluids, :job_id
    add_index :fluids, :company_id
    add_index :fluids, :entry_at
  end
end

