class AddPayrollScheduleToCompanies < ActiveRecord::Migration
    def change
        add_column :companies, :payroll_schedule, :integer, :default => 1
    end
end
