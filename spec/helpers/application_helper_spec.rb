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
  
  [['dashboard', ['index', 'video_playback']], ['content', ['about_us', 'blog', 'contact_us', 'mashout', 'blastout', 'pickout', 'shoutout']]].each do |controller_name, action_names|
    action_names.each do |action_name| 
      it "should detect large content for controller #{controller_name}" do
        controller = double(:controller_name => controller_name, :action_name => action_name)
        
        if controller_name == 'dashboard'
          helper.should_receive(:controller).exactly(2).times.and_return(controller)
        else
          helper.should_receive(:controller).exactly(3).times.and_return(controller)
        end
        
        helper.large_content?.should be
      end
    end
  end
  
  it 'should render a conditional haml tag' do
    helper.should_receive(:haml_tag).with(anything, anything)
    helper.conditional_div(true, {})
  end
  
  it 'should render a conditional haml concatenation' do
    helper.should_receive(:haml_concat).with(anything)
    helper.should_receive(:capture_haml)
    helper.conditional_div(false, {}) {}
  end
  
  it 'should sanitize twitter screen name' do
    helper.sanitize_twitter_screen_name('@foo_bar').should eq('foo_bar')
  end
end
