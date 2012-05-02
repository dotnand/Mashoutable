class CreateOutMedia < ActiveRecord::Migration
  def change
    create_table :out_media do |t|
      t.references :out
      t.string :media

      t.timestamps
    end
    add_index :out_media, :out_id
  end
end
