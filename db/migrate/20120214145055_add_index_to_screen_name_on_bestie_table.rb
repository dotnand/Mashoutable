class AddIndexToScreenNameOnBestieTable < ActiveRecord::Migration
  def change
    add_index :besties, :screen_name
  end
end
