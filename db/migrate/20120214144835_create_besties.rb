class CreateBesties < ActiveRecord::Migration
  def change
    create_table :besties do |t|
      t.string :screen_name
      t.integer :user_id

      t.timestamps
    end
  end
end
