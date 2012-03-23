class AddNameIndexToVideos < ActiveRecord::Migration
  def change
    add_index :videos, :name, :name => 'videos_name_idx', :unique => true
  end
end
