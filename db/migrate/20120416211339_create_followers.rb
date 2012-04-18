class CreateFollowers < ActiveRecord::Migration
  def change
    create_table :followers do |t|
      t.integer :twitter_user_id
      t.references :user

      t.timestamps
    end
  end
end
