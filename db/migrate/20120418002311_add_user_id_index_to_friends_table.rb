class AddUserIdIndexToFriendsTable < ActiveRecord::Migration
  def change
    add_index :friends, :user_id, :unique => true
  end
end
