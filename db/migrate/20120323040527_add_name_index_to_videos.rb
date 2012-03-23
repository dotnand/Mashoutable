class AddNameIndexToVideos < ActiveRecord::Migration
  def change
    add_index :videos, [:name, :user_id], :name => 'videos_name_idx', :unique => true
  end
end
