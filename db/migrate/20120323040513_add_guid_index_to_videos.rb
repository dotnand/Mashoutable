class AddGuidIndexToVideos < ActiveRecord::Migration
  def change
    add_index :videos, :guid, :name => 'videos_guid_idx', :unique => true
  end
end
