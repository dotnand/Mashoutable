class CreateOutHashtags < ActiveRecord::Migration
  def change
    create_table :out_hashtags do |t|
      t.string :tag
      t.integer :out_id

      t.timestamps
    end
  end
end
