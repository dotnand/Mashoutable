require 'spec_helper'

describe Video do
  before do
    FactoryGirl.create(:video)
  end

  it { should belong_to(:user) }
  it { should validate_presence_of(:guid) }
  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:guid).scoped_to(:user_id) }
  it { should validate_uniqueness_of(:name).scoped_to(:user_id) }
end
