class AddOutIdToInteractions < ActiveRecord::Migration
  def change
    add_column :interactions, :out_id, :integer
  end
end
