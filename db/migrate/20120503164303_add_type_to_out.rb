class AddTypeToOut < ActiveRecord::Migration
  def change
    add_column :outs, :type, :string
  end
end
