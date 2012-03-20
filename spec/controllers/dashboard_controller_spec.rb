require 'shared_context/twitter_profiles'
require 'shared_context/grouped_augmented_interactions'
require 'shared_context/twitter_besties'
require 'shared_context/videos'
require 'spec_helper'

describe DashboardController do
  include_context 'twitter profiles'
  include_context 'grouped augmented interactions'
  include_context 'twitter besties'
  include_context 'user videos'
  
  let(:current_user)  { FactoryGirl.create(:user) }
  let(:twitter)       { mock('twitter') }
  let(:facebook)      { mock('facebook') }
  
  before do
    subject.stub(:current_user) { current_user }
    current_user.stub(:twitter) { twitter }
    current_user.stub(:facebook) { facebook }
  end

  def setup_current_user_twitter_besties
    current_user.should_receive(:twitter_besties).and_return(twitter_besties)
  end
  
  def setup_current_user_videos
    current_user.should_receive(:videos).and_return(videos)
  end

  def setup_current_user_grouped_augmented_interactions
   current_user.should_receive(:grouped_augmented_interactions).and_return(grouped_augmented_interactions)
  end

  context 'besties' do
    before do
      setup_current_user_twitter_besties
    end
  
    it 'should GET besties' do
      get :besties
      
      response.should be_success
      assigns[:besties].should eq(twitter_besties_paginated)  
    end
    
    context 'from twitter' do
      let(:besties) { mock('besties') }
      
      before do
        current_user.should_receive(:besties).and_return(besties)
      end
      
      it 'should DELETE bestie given it exists' do
        bestie  = mock('bestie')
        
        bestie.should_receive(:destroy)
        bestie.should_receive(:screen_name).and_return('bestie2')
        besties.should_receive(:find_by_screen_name).with('bestie2').and_return(bestie)
        
        delete :delete_bestie, {'bestie' => 'bestie2'}
        
        assigns[:message].should eq('Removed bestie2 bestie')
        assigns[:besties].should eq(twitter_besties_paginated)
      end
      
      it 'should not DELETE bestie if one does not exist' do
        besties.should_receive(:find_by_screen_name).with('bestie2').and_return(nil)
        
        delete :delete_bestie, {'bestie' => 'bestie2'}
        
        assigns[:message].should eq('Bestie bestie2 not found')
        assigns[:besties].should eq(twitter_besties_paginated)
      end

      it 'should POST a new bestie' do
        bestie = mock('bestie')
        
        bestie.should_receive(:save).and_return(true)
        besties.should_receive(:create).with(:screen_name => '@bestie2').and_return(bestie)
        
        post :create_bestie, {'bestie' => 'bestie2'}
        
        assigns[:message].should eq('Bestie @bestie2 created')
        assigns[:besties].should eq(twitter_besties_paginated)
      end
      
      it 'should not POST a new bestie if bestie exists ' do
        bestie = mock('bestie')
        
        bestie.should_receive(:save).and_return(false)
        besties.should_receive(:create).with(:screen_name => '@bestie2').and_return(bestie)
        
        post :create_bestie, {'bestie' => 'bestie2'}
        
        assigns[:message].should eq('Unable to create @bestie2')
        assigns[:besties].should eq(twitter_besties_paginated)
      end  
    end
  end

  it 'should GET videos' do
    setup_current_user_videos
    get :videos
    response.should be_success
    assigns[:videos].should eq(videos_paginated)
  end  
  
  context 'update a video' do
    it 'should be successful given a guid and name' do
      post :update_video, {:guid => '1234', :name => 'new video name'}
      response.should be_success
    end
    
    it 'should not be successful without a name' do
      post :update_video, {:guid => '1234'}
      response.body.should eq('Name is blank')
    end
  end
  
  context 'video playback' do
    let(:playback_videos) { mock('videos') }

    it 'should play when given a guid' do
      Video.should_receive(:find_by_guid).with('123').and_return(videos_paginated.first)
      get :video_playback, :guid => '123'
      assigns[:video].should eq(videos_paginated.first)
    end
    
    it 'should redirect to homepage if video was not found or given' do
      get :video_playback
      response.should be_redirect
      flash[:notice].should eq('Sorry, but the video you requested was not found')
    end    
  end

  context 'build a tweet' do
    let(:params)  { {} }
    let(:emitter) { mock('emitter') }
    let(:tweet)   { 'trend1 #trend2' }
    
    def setup_emitter_errors(msg)
      errors        = mock('errors')
      full_messages = mock('full_messages')

      full_messages.should_receive(:to_sentence).and_return(msg)
      errors.should_receive(:any?).and_return(true)
      errors.should_receive(:full_messages).and_return(full_messages)
      emitter.should_receive(:errors).exactly(2).times.and_return(errors)
    end
    
    def setup_emitter(params, tweet)
      out = mock('out')

      out.should_receive(:user=)
      Out.should_receive(:new).and_return(out)
      TweetEmitter.should_receive(:new).with(current_user, out).and_return(emitter)
      emitter.should_receive(:validate!).and_return(tweet.length > 0)
      
      if tweet.length < 1
        setup_emitter_errors('OUT can not be empty')
      elsif not params.has_key?('mashout-network-twitter') and not params.has_key?('mashout-network-facebook')
        setup_emitter_errors('Network must be choosen')
      else
        emitter.should_receive(:queued_emit?).and_return(false)
        emitter.should_receive(:errors).and_return([])
        emitter.should_receive(:emit).with(out).and_return(tweet)
      end
    end
    
    def build_params(action)
      params.merge!({'out'                      => tweet, 
                     'trend-source'             => 'Google', 
                     'mashout-trend'            => ['trend1', '#trend2'], 
                     'mashout-network-twitter'  => 'true',
                     'controller'               => 'dashboard',
                     'action'                   => action})
    end
    
    it 'should GET preview mashout' do
      build_params('preview_mashout')
      
      get :preview_mashout, params

      response.should be_success
      response.body.should eq('trend1 #trend2')
    end  
    
    it 'should GET preview mashout with video' do
      video_guid  = '123abc'
      bitly       = mock('bitly')
      
      FactoryGirl.create(:video, :guid => video_guid, :user => current_user)
      
      bitly.should_receive(:shorten) { true }
      bitly.should_receive(:shortened_url).and_return('http://out.am/9a8b7c')
      Bitly::Client.should_receive(:new).with("http://127.0.0.1/videos/#{video_guid}").and_return(bitly)
          
      build_params('preview_mashout')
      
      get :preview_mashout, params.merge!({'mashout-video' => video_guid})

      response.should be_success
      response.body.should eq('trend1 #trend2 http://out.am/9a8b7c')
    end
    
    context 'POST' do    
      def create_out_should_be_successful(redirected_to, tweet)
        flash[:success].should eq('Created your OUT!')
        assigns[:out].should eq(tweet)
      end
    
      it 'should create a shoutout' do
        build_params('create_shoutout')
        setup_emitter(params, tweet)
        
        post :create_shoutout, params
        
        create_out_should_be_successful(dashboard_shoutout_path, tweet)
        response.should be_redirect
      end
      
      it 'should create a mashout' do
        build_params('create_mashout')
        setup_emitter(params, tweet)
        
        post :create_mashout, params
        
        create_out_should_be_successful(dashboard_mashout_path, tweet)
        response.should be_redirect
      end
      
      it 'should create a blastout' do
        build_params('create_blastout')
        setup_emitter(params, tweet)
        
        post :create_blastout, params
        
        create_out_should_be_successful(dashboard_blastout_path, tweet)
        response.should be_redirect
      end
    end
    
    [[:create_shoutout, 'create shoutout'], [:create_mashout, 'create mashout'], [:create_blastout, 'create blastout']].each do |action, desc|
      it "should not redirect on create #{desc} failure" do
        out = mock('out')

        out.should_receive(:user=)
        Out.should_receive(:new).and_return(out)
        TweetEmitter.should_receive(:new).with(current_user, out) { raise Exception.new('test failure') }
        post action, params.merge!({'mashout-network-twitter'  => 'true'})
        flash[:error].should eq('Unable to your send your OUT.  test failure')
      end
    end
    
    it 'should warn if the tweet content is blank' do
      tweet = ''
      
      build_params('create_mashout')
      params['out'] = ''
      setup_emitter(params, tweet)

      post :create_mashout, params

      flash[:error].should eq('OUT can not be empty')
      assigns[:out].should eq('')
    end
    
    it 'should error if there no networks have been selected' do
      params['out'] = 'hello!!!'
      setup_emitter(params, params['out'])

      post :create_blastout, params

      flash[:error].should eq('Network must be choosen')
    end
  end
 
  it 'GET targets' do
    mentions        = [{:screen_name => 'john_doe', 'text' => 'foo'}, {:screen_name => 'jane_doe', 'text' => 'bar'}]
    tweet_builder   = mock('object')
    params          = {'mashout-target' => 'MENTIONS'}
    
    tweet_builder.should_receive(:target).with('MENTIONS', false).and_return([mentions, nil])
    TweetBuilder.should_receive(:new).with(current_user).and_return(tweet_builder)
    
    get :targets, params
    
    response.should be_success
    assigns[:targets].should eq({"john_doe"=>[{"screen_name"=>"john_doe", "text"=>"foo"}], "jane_doe"=>[{"screen_name"=>"jane_doe", "text"=>"bar"}]})
  end

  context 'GET trends' do
    it 'should get trends given a Google source' do
      trends        = ['trend 1', 'trend 2', 'trend 3']
      trend_lookup  = [trends, nil, nil]
      
      Trend.should_receive(:trends).with(current_user, 'Google', nil, nil).and_return([nil, nil, ['trend 1', 'trend 2', 'trend 3']])

      get :trends, {:trend_source => 'Google'}

      assigns[:trends].should eq(trends)
      response.should be_success
    end
    
    it 'should get locations given a Twitter source' do
      locations     = [{'name' => 'United States', 'value' => 12345}, {'name' => 'China', 'value' => 54321}, {'name' => 'Spain', 'value' => 878787}] 
      trend_lookup  = [locations, nil, nil]
      Trend.should_receive(:trends).with(current_user, 'Twitter', nil, nil).and_return(trend_lookup)
      
      get :trends, {:trend_source => 'Twitter'}
      
      assigns[:locations].should eq(locations)
      response.should be_success
    end    
  end

  it 'GET should redirect to root when not signed in' do
    subject.stub(:current_user) { nil }
    
    get :index      
    response.should redirect_to(root_path)
    get :mashout
    response.should redirect_to(root_path)
    get :blastout
    response.should redirect_to(root_path)
    get :shoutout
    response.should redirect_to(root_path)
    get :signout
    response.should redirect_to(root_path)
  end
  
  it 'GET index should be successful' do
    setup_current_user_twitter_besties
    setup_current_user_videos
    setup_current_user_grouped_augmented_interactions
    
    get :index
    
    response.should be_success
    assigns[:besties].should eq(twitter_besties_paginated)
    assigns[:videos].should eq(videos_paginated)
    assigns[:interactions].should eq(grouped_augmented_interactions)
    assigns[:networks].should_not be_nil
  end
  
  it 'GET tool should be successful' do
    get :tool
    response.should be_redirect
  end
  
  it 'GET mashout should be successful' do
    get :mashout
    response.should be_success
  end
  
  it 'GET blastout should be successful' do
    setup_current_user_videos
    
    get :blastout

    response.should be_success
    assigns[:videos].should eq(videos_paginated)
  end
  
  it 'GET shoutout should be successful' do
    get :shoutout
    response.should be_success
  end
    
  context 'networks' do
    let(:params) {{'mashout-network-twitter'  => 'false',
                   'mashout-network-facebook' => 'false',
                   'mashout-network-youtube'  => 'false',
                   'controller'               => 'dashboard',
                   'action'                   => 'remove_networks'}}
    
    it 'should remove networks' do
      current_user.should_receive(:remove_networks).with(params).and_return(true)
      delete :remove_networks, params

      assigns[:message].should eq('Updated your connected networks!')
      assigns[:networks].should be
    end
    
    it 'should provide error message when failure to remove networks' do
      current_user.should_receive(:remove_networks).with(params).and_return(false)
      current_user.should_receive(:errors).and_return(double(:full_messages => ['Must have at least Twitter or Facebook enabled to use Mashoutable']))
      delete :remove_networks, params

      assigns[:message].should eq('Must have at least Twitter or Facebook enabled to use Mashoutable')
      assigns[:networks].should be
    end
  end
    
  it 'POST should create video should be successful' do
    video = mock('video')

    video.should_receive(:save).and_return(true)
    Video.should_receive(:new).with(:guid => '1245', :name => 'my video', :user => current_user).and_return(video)

    post :create_video, {'guid' => '1245', 'name' => 'my video'}

    response.should be_success
  end
  
  it 'should DELETE a video given a guid' do
    user_videos = mock('videos')
    
    videos_paginated.first.should_receive(:destroy)
    videos.should_receive(:find_by_guid).with('123').and_return(videos_paginated.first)
    current_user.should_receive(:videos).exactly(2).times.and_return(videos)
    
    delete :delete_video, {'guid' => '123'}
    
    response.should be_success
    assigns[:videos].should_not be_nil
  end
  
  context 'POST video' do
    it 'should fail given no guid and name' do
      post :create_video
      response.should be_success
      response.body.should eq('Video was not supplied')
    end
    
    it 'should fail given guid and no name' do
      post :create_video, {'guid' => '1234'}
      response.should be_success
      response.body.should eq('Please supply a video name')
    end
    
    it 'should fail if video guid has been already taken' do
      FactoryGirl.create(:video, :guid => '1234', :user => current_user)
      post :create_video, {'guid' => '1234', 'name' => 'my video'}
      response.should be_success
      response.body.should eq('Video has already been saved')
    end    
    
    it 'should fail if video name has been already taken' do
      FactoryGirl.create(:video, :guid => '1234', :name => 'my video', :user => current_user)
      post :create_video, {'guid' => '9999', 'name' => 'my video'}
      response.should be_success
      response.body.should eq('Video name already has been taken')
    end    
  end
    
  it 'should know the current tool' do
    setup_current_user_twitter_besties
    setup_current_user_grouped_augmented_interactions
    
    get :index
    assigns[:current_tool].should eq(dashboard_path)
  
    get :mashout
    assigns[:current_tool].should eq(dashboard_mashout_path)
    
    get :blastout
    assigns[:current_tool].should eq(dashboard_blastout_path)
    
    get :shoutout
    assigns[:current_tool].should eq(dashboard_shoutout_path)
    
    # TODO: the following tool is temporarily unavailable
    # get :pickout
    # assigns[:current_tool].should eq(dashboard_pickout_path)
  end
  
  context 'available networks' do
    let(:current_user) { FactoryGirl.create(:user) }
    
    before do
      subject.stub(:current_user) { current_user }
    end
  
    it 'should determine twitter authorization' do
      current_user.stub(:twitter).and_return(true) 
      current_user.stub(:facebook).and_return(nil) 
      current_user.stub(:youtube).and_return(nil) 

      get :index

      assigns[:networks].should eq({'twitter' => true, 'facebook' => false, 'youtube' => false})
    end
    
    it 'should determine facebook authorization' do
      current_user.stub(:twitter).and_return(nil)
      current_user.stub(:facebook).and_return(true) 
      current_user.stub(:youtube).and_return(nil) 

      get :index

      assigns[:networks].should eq({'twitter' => false, 'facebook' => true, 'youtube' => false})
    end
    
    it 'should determine facebook authorization' do
      current_user.stub(:twitter).and_return(nil) 
      current_user.stub(:facebook).and_return(nil) 
      current_user.stub(:youtube).and_return(true) 

      get :index

      assigns[:networks].should eq({'twitter' => false, 'facebook' => false, 'youtube' => true})
    end
  end
end
