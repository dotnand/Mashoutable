class AddOutIdIndexToMentions < ActiveRecord::Migration
  def change
    add_index :mentions, :out_id, :name => 'mentions_out_id_idx'
  end
end
