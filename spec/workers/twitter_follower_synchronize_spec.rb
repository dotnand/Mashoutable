require 'spec_helper'

describe TwitterFollowerSynchronize do
  it 'should perform' do
    user = FactoryGirl.create(:user, :id => 1)

    4.times { |n| FactoryGirl.create(:follower, :id => n + 2, :user_id => 1, :twitter_user_id => n + 2) }
    User.should_receive(:page_through_twitter_ids).with(user.twitter, :follower_ids, {}, nil).and_return([4, 5, 6, 7])
    
    TwitterFollowerSynchronize.perform(1)
    
    Follower.all.map(&:twitter_user_id).should eq([4, 5, 6, 7])
    Follower.all.map(&:id).should eq([4, 5, 1, 2])
  end
end
