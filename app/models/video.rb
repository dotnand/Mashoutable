class Video < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :guid, :user, :name
  validates_uniqueness_of :guid, :name, :scope => :user_id
end
