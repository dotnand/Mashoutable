class Reply < ActiveRecord::Base
  belongs_to :user
  belongs_to :out
  validates_presence_of :status_id, :out
  validates_uniqueness_of :status_id, :scope => :user_id
end
