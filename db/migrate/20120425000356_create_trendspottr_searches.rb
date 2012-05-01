class CreateTrendspottrSearches < ActiveRecord::Migration
  def change
    create_table :trendspottr_searches do |t|
      t.string :name

      t.timestamps
    end
  end
end
