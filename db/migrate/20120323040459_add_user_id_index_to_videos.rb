class AddUserIdIndexToVideos < ActiveRecord::Migration
  def change
    add_index :videos, :user_id, :name => 'videos_user_id_idx'
  end
end
