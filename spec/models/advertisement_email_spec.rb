require 'spec_helper'

describe AdvertisementEmail do
  before(:each) do
    @advertisement = FactoryGirl.create(:advertisement)
    @advertisement_email = FactoryGirl.create(:advertisement_email, :advertisement => @advertisement)
  end

  [:advertisement, :email].each do |required|
  	it { should validate_presence_of(required) }
  end

  it { should validate_uniqueness_of(:email).scoped_to(:advertisement_id).with_message(/used once/) }
  it { should validate_format_of(:email).with('foo@foo.com') }
  it { should validate_format_of(:email).not_with('foo@foo').with_message(/is invalid/) }
end
