class RemoveContentFromInteractions < ActiveRecord::Migration
  def up
    remove_column :interactions, :content
  end

  def down
    add_column :interactions, :content, :string
  end
end
