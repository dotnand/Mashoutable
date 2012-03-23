class AddProviderIndexToAuthorizations < ActiveRecord::Migration
  def change
    add_index :authorizations, :provider, :name => 'authorizations_provider_idx'
  end
end
