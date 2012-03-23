class AddGuidIndexToVideos < ActiveRecord::Migration
  def change
    add_index :videos, [:guid, :user_id], :name => 'videos_guid_idx', :unique => true
  end
end
