require 'spec_helper'

describe CacheVerifiedTwitterUser do
  it 'should capture verified accounts' do
    6.times { FactoryGirl.create(:verified_twitter_user) }

    mashoutable_twitter_client = mock('mashoutable twitter client')

    VerifiedTwitterUser.should_receive(:remote_twitter_ids).and_return([1, 2, 3, 5, 8, 13])

    CacheVerifiedTwitterUser.perform
    
    VerifiedTwitterUser.all.map(&:user_id).should eq([1, 2, 3, 5, 8, 13])
  end
end
