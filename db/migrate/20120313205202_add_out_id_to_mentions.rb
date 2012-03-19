class AddOutIdToMentions < ActiveRecord::Migration
  def change
    add_column :mentions, :out_id, :integer
  end
end
