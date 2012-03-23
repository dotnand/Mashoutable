class AddUidIndexToAuthorizations < ActiveRecord::Migration
  def change
    add_index :authorizations, :uid, :name => 'authorizations_uid_idx', :unique => true
  end
end
