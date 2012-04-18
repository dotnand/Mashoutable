require 'spec_helper'

describe Follower do
  before do
    FactoryGirl.create(:follower)
  end

  it { should belong_to :user}
  it { should validate_presence_of :twitter_user_id }
  it { should validate_uniqueness_of(:twitter_user_id).scoped_to(:user_id) }
end
