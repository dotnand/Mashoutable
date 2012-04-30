require 'spec_helper'

describe Friend do
  before do
    FactoryGirl.create(:friend)
  end

  it { should belong_to :user}
  it { should validate_presence_of :twitter_user_id }
  it { should validate_uniqueness_of(:twitter_user_id).scoped_to(:user_id) }
end
