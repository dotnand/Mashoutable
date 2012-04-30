require 'spec_helper'

describe TrendspottrTopic do
  before do
    FactoryGirl.create(:trendspottr_topic)
  end

  it{ should validate_presence_of(:name) }
  it{ should validate_uniqueness_of(:name) }
end
