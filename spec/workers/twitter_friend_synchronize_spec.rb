require 'spec_helper'

describe TwitterFriendSynchronize do
  it 'should perform' do
    user = FactoryGirl.create(:user, :id => 1)
    friends = []

    4.times { |n| friends << FactoryGirl.create(:friend, :user_id => 1) }
    User.should_receive(:page_through_twitter_ids).with(user.twitter, :friend_ids, {}, nil).and_return(friends.map(&:twitter_user_id))

    TwitterFriendSynchronize.perform(1)

    Friend.all.map(&:twitter_user_id).should eq(friends.map(&:twitter_user_id))
    Friend.all.map(&:id).should eq(friends.map(&:id))
  end
end

