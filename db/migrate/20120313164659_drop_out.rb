class DropOut < ActiveRecord::Migration
  def up
    drop_table :outs    
  end
end
