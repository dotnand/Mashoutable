require 'spec_helper'

describe Mention do
  before do
    FactoryGirl.create(:mention)
  end
  
  it { should belong_to :user }
  it { should belong_to :out }
  it { should validate_presence_of :out }
  it { should validate_presence_of :who }
  it { should validate_uniqueness_of(:who).scoped_to(:user_id) }
end
