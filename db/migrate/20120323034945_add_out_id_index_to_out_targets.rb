class AddOutIdIndexToOutTargets < ActiveRecord::Migration
  def change
    add_index :out_targets, :out_id, :name => 'out_targets_out_id_idx'
  end
end
