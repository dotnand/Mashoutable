require 'spec_helper'

describe AuthorizationController do
  let(:omniauth) { {} }
  let(:auth) { double(:user => FactoryGirl.create(:user, :id => 1)) }

  before do
    request.env['omniauth.auth'] = omniauth
  end

  def should_show_synchronize_message
    flash[:notice].should eq("It appears like we don't have your friends or followers.  Please wait a few minutes while we provision your account.")
  end

  def should_synchronize
    auth.user.should_receive(:synchronize).and_return(Time.now)
  end

  def post_create
    post :create, :provider => "twitter"
    response.should redirect_to(dashboard_blastout_url)
  end

  def should_not_create_an_authorization
    Authorization.should_receive(:find_from_hash).with(omniauth).and_return(auth)
    Authorization.should_not_receive(:create_from_hash)
    post_create
  end

  context 'without prior login' do
    it 'should create an authorization' do
      Authorization.should_receive(:find_from_hash).with(omniauth).and_return(nil)
      Authorization.should_receive(:create_from_hash).with(omniauth, nil).and_return(auth)
      post_create
    end

    it 'should not create an authorization' do
      should_not_create_an_authorization
    end
  end

  context 'with prior login' do
    let(:current_user) { FactoryGirl.build(:user) }

    before do
      subject.stub(:current_user) { current_user }
    end

    it 'should create an authorization' do
      Authorization.should_receive(:find_from_hash).with(omniauth).and_return(nil)
      Authorization.should_receive(:create_from_hash).with(omniauth, current_user).and_return(auth)
      post_create
    end

    it 'should not create an authorization' do
      should_not_create_an_authorization
    end
  end

  it 'should show a failure page on authorization failure' do
    get :failure, {:message => 'uhoh'}
    assigns[:message].should eq('uhoh')
  end
end

