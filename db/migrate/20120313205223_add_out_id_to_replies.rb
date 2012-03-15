class AddOutIdToReplies < ActiveRecord::Migration
  def change
    add_column :replies, :out_id, :integer
  end
end
