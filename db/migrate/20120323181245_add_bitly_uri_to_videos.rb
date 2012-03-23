class AddBitlyUriToVideos < ActiveRecord::Migration
  def change
    add_column :videos, :bitly_uri, :string
  end
end
