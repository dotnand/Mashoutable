class AddOutIdIndexToReplies < ActiveRecord::Migration
  def change
    add_index :replies, :out_id, :name => 'replies_out_id_idx'
  end
end
