class AddUserIdIndexToReplies < ActiveRecord::Migration
  def change
    add_index :replies, :user_id, :name => 'replies_user_id_index'
  end
end
