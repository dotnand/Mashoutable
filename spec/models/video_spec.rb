require 'spec_helper'

describe Video do
  before do
    FactoryGirl.create(:video)
  end

  it { should belong_to(:user) }
  it { should validate_presence_of(:guid).with_message(/was not supplied/) }
  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:name).with_message(/was not supplied/) }
  it { should validate_uniqueness_of(:guid).scoped_to(:user_id).with_message(/has already been saved/) }
  it { should validate_uniqueness_of(:name).scoped_to(:user_id).with_message(/has already been taken/) }
end
