class RenameTrendToTrendSourceOnOuts < ActiveRecord::Migration
  def change
    rename_column :outs, :trend, :trend_source    
  end
end
