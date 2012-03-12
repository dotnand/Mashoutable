require 'spec_helper'

describe Bestie do
  before do
    FactoryGirl.create(:bestie)
  end

  it { should belong_to(:user) }
  it { should validate_presence_of(:screen_name) }
  it { should validate_uniqueness_of(:screen_name).scoped_to(:user_id) }
  
  it "screen name should start with an '@' symbol" do
    bestie = FactoryGirl.build(:bestie, :screen_name => 'user1')
    bestie.valid?.should be_false
    bestie.screen_name = '@user1'
    bestie.save.should be_true
  end
end
