class CreateOutErrors < ActiveRecord::Migration
  def change
    create_table :out_errors do |t|
      t.references :out
      t.string :source
      t.string :error

      t.timestamps
    end
    add_index :out_errors, :out_id
  end
end
