class AddPendingToOut < ActiveRecord::Migration
  def change
    add_column :outs, :pending, :boolean, :default => false
  end
end
