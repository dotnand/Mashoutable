class CreateInteractions < ActiveRecord::Migration
  def change
    create_table :interactions do |t|
      t.text :content
      t.string :target
      t.integer :user_id

      t.timestamps
    end
  end
end
