class AddPendingToOut < ActiveRecord::Migration
  def change
    change_column :outs, :pending, :boolean, :default => 1
  end
end
