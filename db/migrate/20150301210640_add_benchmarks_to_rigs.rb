class AddBenchmarksToRigs < ActiveRecord::Migration
  def change
    add_column :rigs, :benchmark_wtw, :integer, default: 350
    add_column :rigs, :benchmark_connection, :integer, default: 80
    add_column :rigs, :benchmark_treatment, :integer, default: 230
    add_column :rigs, :benchmark_bottom, :integer, default: 1400
    add_column :rigs, :benchmark_tripping_in_connection, :integer, default: 40
    add_column :rigs, :benchmark_tripping_in_pipe, :integer, default: 30
    add_column :rigs, :benchmark_tripping_out_connection, :integer, default: 40
    add_column :rigs, :benchmark_tripping_out_pipe, :integer, default: 20

  end
end
