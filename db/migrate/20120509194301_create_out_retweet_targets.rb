class CreateOutRetweetTargets < ActiveRecord::Migration
  def change
    create_table :out_retweet_targets do |t|
      t.references :out
      t.string :target
      t.string :status_id

      t.timestamps
    end
    add_index :out_retweet_targets, :out_id
  end
end
