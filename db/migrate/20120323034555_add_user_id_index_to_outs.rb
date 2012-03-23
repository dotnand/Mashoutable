class AddUserIdIndexToOuts < ActiveRecord::Migration
  def change
    add_index :outs, :user_id, :name => 'outs_user_id_idx'
  end
end
