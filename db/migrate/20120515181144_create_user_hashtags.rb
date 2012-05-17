class CreateUserHashtags < ActiveRecord::Migration
  def change
    create_table :user_hashtags do |t|
      t.references :user
      t.string :tag

      t.timestamps
    end
    add_index :user_hashtags, :user_id
  end
end
