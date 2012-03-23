class AddUserIdIndexToBesties < ActiveRecord::Migration
  def change
    add_index :besties, :user_id, :name => 'besties_user_id_idx'
  end
end
