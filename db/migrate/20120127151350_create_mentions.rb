class CreateMentions < ActiveRecord::Migration
  def change
    create_table :mentions do |t|
      t.integer :user_id
      t.string :who

      t.timestamps
    end
  end
end
