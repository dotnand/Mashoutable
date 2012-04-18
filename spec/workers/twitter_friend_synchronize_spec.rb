require 'spec_helper'

describe TwitterFriendSynchronize do
  it 'should perform' do
    user = FactoryGirl.create(:user, :id => 1)

    4.times { |n| FactoryGirl.create(:friend, :id => n + 2, :user_id => 1, :twitter_user_id => n + 2) }
    User.should_receive(:page_through_twitter_ids).with(user.twitter, :friend_ids, {}, nil).and_return([4, 5, 6, 7])
    
    TwitterFriendSynchronize.perform(1)
    
    Friend.all.map(&:twitter_user_id).should eq([4, 5, 6, 7])
    Friend.all.map(&:id).should eq([4, 5, 1, 2])
  end
end
