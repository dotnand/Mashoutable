class CreateOutReplies < ActiveRecord::Migration
  def change
    create_table :out_replies do |t|
      t.string :reply
      t.integer :out_id

      t.timestamps
    end
  end
end
