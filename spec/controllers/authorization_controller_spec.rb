require 'spec_helper'

describe AuthorizationController do
  let(:omniauth) { {} }
  let(:auth) { double(:user => FactoryGirl.create(:user, :id => 1)) }

  before do
    request.env['omniauth.auth'] = omniauth
  end

  def post_create
    post :create, :provider => "twitter"
    response.should redirect_to(dashboard_path)      
  end

  def should_not_create_an_authorization
    Authorization.should_receive(:find_from_hash).with(omniauth).and_return(auth)
    Authorization.should_not_receive(:create_from_hash)
    post_create 
  end

  context 'without prior login' do
    it 'should create an authorization' do
      auth.user.should_receive(:synchronize)
      Authorization.should_receive(:find_from_hash).with(omniauth).and_return(nil)
      Authorization.should_receive(:create_from_hash).with(omniauth, nil).and_return(auth)
      post_create 
    end
    
    it 'should not create an authorization' do
      auth.user.should_receive(:synchronize)
      should_not_create_an_authorization
    end
  end
  
  context 'with prior login' do
    let(:current_user) { FactoryGirl.build(:user) }

    before do
      subject.stub(:current_user) { current_user }
    end    
    
    it 'should create an authorization' do
      current_user.should_receive(:synchronize)
      Authorization.should_receive(:find_from_hash).with(omniauth).and_return(nil)
      Authorization.should_receive(:create_from_hash).with(omniauth, current_user).and_return(auth)
      post_create
    end
    
    it 'should not create an authorization' do
      current_user.should_receive(:synchronize)
      should_not_create_an_authorization
    end
  end
  
  it 'should show a failure page on authorization failure' do
    get :failure, {:message => 'uhoh'}
    assigns[:message].should eq('uhoh')
  end
end
