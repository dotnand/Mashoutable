class CreateVerifiedTwitterUsers < ActiveRecord::Migration
  def change
    create_table :verified_twitter_users do |t|
      t.integer :user_id

      t.timestamps
    end
  end
end
