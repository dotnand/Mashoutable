class OutError < ActiveRecord::Base
  belongs_to :out
  validates_presence_of :out, :source, :error
end

