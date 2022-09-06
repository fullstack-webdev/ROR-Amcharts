class AddFailuresCount < ActiveRecord::Migration
  def up
      add_column :jobs, :failures_count, :integer, :default => 0

      Job.reset_column_information
      Job.find_each do |p|
          Job.update_counters p.id, :failures_count => p.failures.count
      end
  end

  def down
      remove_column :jobs, :failures_count
  end
end
