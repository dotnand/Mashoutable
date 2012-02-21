class Video < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :guid
  validates_presence_of :user
end
