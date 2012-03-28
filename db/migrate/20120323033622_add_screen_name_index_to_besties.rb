class AddScreenNameIndexToBesties < ActiveRecord::Migration
  def change
    add_index :besties, [:screen_name, :user_id], :name => 'besties_screen_name_idx', :unique => true
  end
end
