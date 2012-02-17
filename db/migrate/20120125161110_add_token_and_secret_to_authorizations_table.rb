class AddTokenAndSecretToAuthorizationsTable < ActiveRecord::Migration
  def up
    add_column :authorizations, :token, :string
    add_column :authorizations, :secret, :string
  end
  
  def down
    drop_column :authorizations, :token
    drop_column :authorizations, :secret
  end
end
