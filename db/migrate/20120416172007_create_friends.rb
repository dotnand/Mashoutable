class CreateFriends < ActiveRecord::Migration
  def change
    create_table :friends do |t|
      t.integer :twitter_user_id
      t.references :user

      t.timestamps
    end
  end
end
