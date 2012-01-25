require 'spec_helper'

describe DashboardController do
  it 'GET index should be successful' do
    get :index
    response.code.should eq('200')
  end
  
  it 'GET tool should be successful' do
    get :tool
    response.code.should eq('302')
  end
  
  it 'GET mashout should be successful' do
    get :mashout
    response.code.should eq('200')
  end
  
  it 'GET blastout should be successful' do
    get :blastout
    response.code.should eq('200')
  end
  
  it 'GET shoutout should be successful' do
    get :shoutout
    response.code.should eq('200')
  end
  
  it 'GET pickout should be successful' do
    get :pickout
    response.code.should eq('200')
  end
  
  it 'GET shoutout should be successful' do
    get :shoutout
    response.code.should eq('200')
  end
  
  it 'GET signout should be successful' do
    pending do
      get :shoutout
      response.code.should eq('302')
    end
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
