class Mention < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :who
  validates_uniqueness_of :who, :scope => :user_id
end
