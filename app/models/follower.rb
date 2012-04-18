class Follower < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :twitter_user_id
end
