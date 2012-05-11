class CreateAdvertisements < ActiveRecord::Migration
  def change
    create_table :advertisements do |t|
      t.string :image_path
      t.datetime :start_date
      t.datetime :end_date

      t.timestamps
    end
  end
end
