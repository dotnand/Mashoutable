class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.string :guid
      t.integer :user_id

      t.timestamps
    end
  end
end
