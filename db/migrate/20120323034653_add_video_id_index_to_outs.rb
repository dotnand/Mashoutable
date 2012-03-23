class AddVideoIdIndexToOuts < ActiveRecord::Migration
  def change
    add_index :outs, :video_id, :name => 'outs_video_id_idx'
  end
end
