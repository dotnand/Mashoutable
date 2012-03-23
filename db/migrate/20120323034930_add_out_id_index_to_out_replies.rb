class AddOutIdIndexToOutReplies < ActiveRecord::Migration
  def change
    add_index :out_replies, :out_id, :name => 'out_replies_out_id_idx'
  end
end
