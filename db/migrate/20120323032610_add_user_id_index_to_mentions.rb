class AddUserIdIndexToMentions < ActiveRecord::Migration
  def change
    add_index :mentions, :user_id, :name => 'mentions_user_id_index'
  end
end
