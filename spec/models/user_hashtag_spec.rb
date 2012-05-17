require 'spec_helper'

describe UserHashtag do
  before(:all) do
    FactoryGirl.create(:user_hashtag)
  end

  [:user, :tag].each do |required|
    it { should validate_presence_of(required) }
  end
  it { should belong_to(:user) }
  it { should validate_format_of(:tag).with('#hashtag').with_message(/is not a valid hashtag/) }
  it { should validate_format_of(:tag).not_with('hash#tag').with_message(/is not a valid hashtag/) }
  it { should validate_uniqueness_of(:tag).scoped_to(:user_id).with_message(/has already been created/)}
end
