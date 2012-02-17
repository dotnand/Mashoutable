class AddStatusIdIndexToReplies < ActiveRecord::Migration
  def change
    add_index :replies, :status_id
  end
end
