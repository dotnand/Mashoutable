class AddScreenNameIndexToBesties < ActiveRecord::Migration
  def change
    remove_index :besties, :name => 'index_besties_on_screen_name'
    add_index :besties, :screen_name, :name => 'besties_screen_name_idx', :unique => true
  end
end
