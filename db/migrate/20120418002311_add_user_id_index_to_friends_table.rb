class AddUserIdIndexToFriendsTable < ActiveRecord::Migration
  def change
    add_index :friends, [:user_id, :twitter_user_id], :unique => true
  end
end
