class CreateOutTrends < ActiveRecord::Migration
  def change
    create_table :out_trends do |t|
      t.string :trend
      t.integer :out_id

      t.timestamps
    end
  end
end
