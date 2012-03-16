class Mention < ActiveRecord::Base
  belongs_to :user
  belongs_to :out
  validates_presence_of :who, :out
  validates_uniqueness_of :who, :scope => :user_id
end
