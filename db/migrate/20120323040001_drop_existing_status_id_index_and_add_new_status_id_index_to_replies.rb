class DropExistingStatusIdIndexAndAddNewStatusIdIndexToReplies < ActiveRecord::Migration
  def change
    remove_index :replies, :name => 'index_replies_on_status_id'
    add_index :replies, [:status_id, :user_id], :name => 'replies_status_id_idx'
  end
end
