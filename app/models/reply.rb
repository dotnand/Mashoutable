class Reply < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :status_id
  validates_uniqueness_of :status_id, :scope => :user_id
end
