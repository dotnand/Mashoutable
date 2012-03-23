class AddUserIdIndexToInteractions < ActiveRecord::Migration
  def change
    add_index :interactions, :user_id, :name => 'interactions_user_id_idx'
  end
end
