class AddUserIdIndexToVerifiedTwitterUsersTable < ActiveRecord::Migration
  def change
    add_index :verified_twitter_users, :user_id
  end
end
