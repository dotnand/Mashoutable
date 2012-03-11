require 'spec_helper'

describe ApplicationHelper do
  let(:helper) do 
    helper = Object.new 
    helper.extend(ApplicationHelper)
  end
  
  it 'should have a twitter auth path' do
    helper.twitter_auth_path.should eq('/auth/twitter')   
  end
  
  it 'should have a facebook auth path' do
    helper.facebook_auth_path.should eq('/auth/facebook')
  end

  it 'should have a youtube auth path' do
    helper.youtube_auth_path.should eq('/auth/google')
  end
  
  it 'should group an array of hashes given a key' do
    first   = {:a => 'foo', :b => 'bar'}
    second  = {:a => 'foo', :b => 'world'}
    third   = {:a => 'super', :b => 'mario'}
    array   = [first, second, third]

    grouped = helper.group_hash_by(array, :a)

    grouped.should have(2).items
    grouped['foo'].first.should eq(first)
    grouped['foo'].second.should eq(second)
    grouped['super'].first.should eq(third)
  end
  
  it 'should group nothing given nothing' do
    helper.group_hash_by(nil, nil).should be_nil
  end
  
  it 'should detect if visiting the dashboard index page' do
    pending
  end
  
  it 'should render a conditional div' do
    pending
  end
  
  it 'should detect large content' do
    pending
  end
  
  it 'should sanitize twitter screen name' do
    helper.sanitize_twitter_screen_name('@foo_bar').should eq('foo_bar')
  end
end
