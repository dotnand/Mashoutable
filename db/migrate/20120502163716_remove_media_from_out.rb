class RemoveMediaFromOut < ActiveRecord::Migration
  def up
    remove_column :outs, :media
  end

  def down
    add_column :outs, :media, :string
  end
end
