require 'spec_helper'

describe Reply do
  before do
    FactoryGirl.create(:reply)
  end

  it { should belong_to :user }
  it { should belong_to :out }
  it { should validate_presence_of :out }
  it { should validate_presence_of :status_id }
end
