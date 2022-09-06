class DropFrictionFactorData < ActiveRecord::Migration
    def change
        if ActiveRecord::Base.connection.table_exists? 'friction_factor_data'
            drop_table :friction_factor_data
        end
    end
end
