class AddUserIdIndexToFollowersTable < ActiveRecord::Migration
  def change
    add_index :followers, [:user_id, :twitter_user_id], :unique => true
  end
end
