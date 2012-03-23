class AddOutIdIndexToInteractions < ActiveRecord::Migration
  def change
    add_index :interactions, :out_id, :name => 'interactions_out_id_idx'
  end
end
