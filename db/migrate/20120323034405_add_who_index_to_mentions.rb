class AddWhoIndexToMentions < ActiveRecord::Migration
  def change
    add_index :mentions, :who, :name => 'mentions_who_idx', :unique => true
  end
end
