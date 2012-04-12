require 'spec_helper'

describe VerifiedTwitterUser do
  it { should validate_presence_of(:user_id) }

  it 'should have unique user ids' do
    FactoryGirl.create(:verified_twitter_user, :user_id => 1)

    verified_user = VerifiedTwitterUser.new(:user_id => 1)
    
    verified_user.save.should_not be
    verified_user.errors[:user_id].should eq(['has already been taken'])
  end
    
  it 'have local verified ids' do
    3.times { FactoryGirl.create(:verified_twitter_user) }
    VerifiedTwitterUser.local_twitter_ids.should eq([1, 2, 3])
  end
  
  it 'should have remote verified ids' do
    twitter_client = mock('twitter client')
    
    User.should_receive(:mashoutable_twitter).and_return(twitter_client)
    User.should_receive(:page_through_twitter_ids).with(twitter_client, :friend_ids, {:screen_name => 'verified'}).and_return([3, 4, 5])
    
    VerifiedTwitterUser.remote_twitter_ids.should eq([3, 4, 5])
  end
  
  it 'should remove a list of twitter ids' do
    6.times { |n| FactoryGirl.create(:verified_twitter_user, :user_id => n) }
    VerifiedTwitterUser.remove_verified([1, 3, 5])
    VerifiedTwitterUser.all.map(&:user_id).should eq([0, 2, 4])
  end
  
  it 'should add a list of twitter ids' do
    VerifiedTwitterUser.add_verified([10, 21, 43])
    VerifiedTwitterUser.all.map(&:user_id).should eq([10, 21, 43])
  end
end
