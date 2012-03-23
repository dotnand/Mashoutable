class AddUserIdIndexToAuthorizations < ActiveRecord::Migration
  def change
    add_index :authorizations, :user_id, :name => 'authorizations_user_id_idx'
  end
end
