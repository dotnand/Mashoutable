class AddScreenNameIndexToBesties < ActiveRecord::Migration
  def change
    remove_index :besties
    add_index :besties, [:screen_name, :user_id], :name => 'besties_screen_name_idx', :unique => true
  end
end
