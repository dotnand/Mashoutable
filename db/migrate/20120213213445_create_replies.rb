class CreateReplies < ActiveRecord::Migration
  def change
    create_table :replies do |t|
      t.string :status_id
      t.integer :user_id

      t.timestamps
    end
  end
  
  def down
    drop_table :replies
  end
end
