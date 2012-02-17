require 'spec_helper'

describe DashboardController do
  let(:current_user) { FactoryGirl.create(:user) }  
  
  before do
    subject.stub(:current_user) { current_user }
  end

  context 'build a tweet' do
    let(:params) { {'controller'       => 'dashboard',
                    'action'           => 'create_mashout'} }
    let(:emitter) { mock('emitter') }
    
    def setup_emitter(params, tweet)
      TweetEmitter.should_receive(:new).with(current_user).and_return(emitter)
      emitter.should_receive(:emit).with(params).and_return(tweet)
    end
    
    it 'GET preview mashout' do
      pending
    end    
    
    context 'POST create' do
      let!(:tweet) { 'trend1 #trend2' }
    
      before do
        params.merge!({'out'              => tweet, 
                       'trend-source'     => 'Google', 
                       'mashout-trend[]'  => 'trend1', 
                       'mashout-trend[]'  => '#trend2'})      
        setup_emitter(params, tweet)
      end
    
      def create_out_should_be_successful(redirected_to, tweet)
        
        flash[:success].should eq('Created your MASHOUT!')
        assigns[:out].should eq(tweet)
      end
    
      it 'should create a shoutout' do
        post :create_shoutout, params
        create_out_should_be_successful(dashboard_shoutout_path, tweet)
        response.should be_redirect
      end
      
      it 'should create a mashout' do
        post :create_mashout, params
        create_out_should_be_successful(dashboard_mashout_path, tweet)
        response.should be_redirect
      end
    end
    
    it 'should warn if the tweet content is blank' do
      tweet   = ''
      
      params.merge!({'out' => ''})
      setup_emitter(params, tweet)
    
      post :create_mashout, params
      
      response.should redirect_to(dashboard_mashout_url)
      flash[:notice].should eq('Ooops, your tweet is empty!')
      assigns[:out].should eq(tweet)
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
    get :pickout
    response.should redirect_to(root_path)
    get :signout
    response.should redirect_to(root_path)
  end
  
  it 'GET index should be successful' do
    get :index
    response.should be_success
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
    get :blastout
    response.should be_success
  end
  
  it 'GET shoutout should be successful' do
    get :shoutout
    response.should be_success
  end
  
  it 'GET pickout should be successful' do
    get :pickout
    response.should be_success
  end
    
  it 'should know the current tool' do
    get :index
    assigns[:current_tool].should eq(dashboard_path)
  
    get :mashout
    assigns[:current_tool].should eq(dashboard_mashout_path)
    
    get :blastout
    assigns[:current_tool].should eq(dashboard_blastout_path)
    
    get :shoutout
    assigns[:current_tool].should eq(dashboard_shoutout_path)
    
    get :pickout
    assigns[:current_tool].should eq(dashboard_pickout_path)
  end
end
