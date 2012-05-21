require 'spec_helper'

describe TwitterFriendSynchronize do
  let(:twitter)       { mock('twitter') }

  context 'without a twitter authorization' do
    it 'should not perform' do
      user    = FactoryGirl.create(:user)
      friends = []

      twitter.should_receive(:present?).and_return(false)
      User.any_instance.stub(:twitter).and_return(twitter)
      User.should_not_receive(:page_through_twitter_ids)

      TwitterFriendSynchronize.perform(user.id)
    end
  end

  context 'with a twitter authorization' do
    it 'should perform' do
      user    = FactoryGirl.create(:user, :id => 1)
      friends = []

      twitter.should_receive(:present?).and_return(:true)
      User.any_instance.stub(:twitter).and_return(twitter)

      4.times { |n| friends << FactoryGirl.create(:friend, :user_id => 1) }
      User.should_receive(:page_through_twitter_ids).with(user.twitter, :friend_ids, {}, nil).and_return(friends.map(&:twitter_user_id))

      TwitterFriendSynchronize.perform(1)

      Friend.all.map(&:twitter_user_id).should eq(friends.map(&:twitter_user_id))
      Friend.all.map(&:id).should eq(friends.map(&:id))
    end
  end
end

