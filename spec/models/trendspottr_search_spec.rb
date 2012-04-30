require 'spec_helper'

describe TrendspottrSearch do
  before do
    FactoryGirl.create(:trendspottr_search)
  end
  
  it{ should validate_presence_of(:name) }
  it{ should validate_uniqueness_of(:name) }
end

