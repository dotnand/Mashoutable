class Video < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :guid
  validates_presence_of :user
  validates_uniqueness_of :guid
  validates_uniqueness_of :name
  validates_presence_of :name
end
