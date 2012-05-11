require 'spec_helper'

describe Advertisement do
  before(:all) do
    @ad1 = FactoryGirl.create(:advertisement, :start_date => Time.now - 2.days,
                                              :end_date   => Time.now + 2.days)
    @ad2 = FactoryGirl.create(:advertisement, :start_date => Time.now.yesterday,
                                              :end_date   => Time.now.tomorrow)
    @ad3 = FactoryGirl.create(:advertisement, :start_date => Time.now.tomorrow,
                                              :end_date => Time.now + 2.days)
  end

  it { should validate_presence_of(:image_path) }
  it { should validate_uniqueness_of(:image_path) }

  describe '#current' do
    it 'should return active advertisements' do
      Advertisement.current.should eq([@ad1, @ad2])
    end
  end

  describe '#random' do
    it 'should return a current advertisement' do
      [@ad1, @ad2].should include(Advertisement.random)
    end
  end
end
