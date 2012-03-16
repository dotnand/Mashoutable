class CreateOutTargets < ActiveRecord::Migration
  def change
    create_table :out_targets do |t|
      t.string :target
      t.integer :out_id

      t.timestamps
    end
  end
end
