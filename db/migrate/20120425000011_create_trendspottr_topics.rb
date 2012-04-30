class CreateTrendspottrTopics < ActiveRecord::Migration
  def change
    create_table :trendspottr_topics do |t|
      t.string :name
      
      t.timestamps
    end
  end
end
