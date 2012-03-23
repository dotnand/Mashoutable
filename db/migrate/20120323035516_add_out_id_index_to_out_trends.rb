class AddOutIdIndexToOutTrends < ActiveRecord::Migration
  def change
    add_index :out_trends, :out_id, :name => 'out_trends_out_id_idx'
  end
end
