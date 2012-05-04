class OutError < ActiveRecord::Base
  belongs_to :out
  validates_presence_of :out, :source, :error

  scope :created_yesterday, lambda { where("created_at BETWEEN ? and ?", (Time.now.midnight - 1.day).to_formatted_s(:db), Time.now.midnight.to_formatted_s(:db)) }
end

