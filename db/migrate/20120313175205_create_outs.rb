class CreateOuts < ActiveRecord::Migration
  def change
    create_table :outs do |t|
      t.string :media
      t.string :trend
      t.string :comment
      t.string :target
      t.boolean :twitter
      t.boolean :facebook
      t.boolean :youtube
      t.integer :user_id
      t.integer :video_id

      t.timestamps
    end
  end
end
