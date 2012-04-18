require 'spec_helper'

describe Friend do
  it { should belong_to :user}
  it { should validate_presence_of :twitter_user_id }
end
