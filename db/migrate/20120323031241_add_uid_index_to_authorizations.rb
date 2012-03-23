class AddUidIndexToAuthorizations < ActiveRecord::Migration
  def change
    add_index :authorizations, [:uid, :provider], :name => 'authorizations_uid_idx', :unique => true
  end
end
