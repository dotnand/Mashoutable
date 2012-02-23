class AddNameToVideo < ActiveRecord::Migration
  def change
    add_column :videos, :name, :string
  end
end
