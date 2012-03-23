class AddOutIdIndexToOutHashtags < ActiveRecord::Migration
  def change
    add_index :out_hashtags, :out_id, :name => 'out_hashtags_out_id_idx'
  end
end
