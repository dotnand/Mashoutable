class AddContentToOut < ActiveRecord::Migration
  def change
    add_column :outs, :content, :string
  end
end
