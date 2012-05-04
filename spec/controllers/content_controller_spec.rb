require 'spec_helper'

describe ContentController do
  it "GET home should be successful" do
    get :home
    response.should render_template("layouts/application")
    response.code.should eq("200")
  end

  it "GET home should redirect to dashboard if logged in" do
    subject.should_receive(:signed_in?).and_return(true)
    get :home
    response.should redirect_to(dashboard_url)
  end

  it "GET about-us should be successful" do
    get :about_us
    response.code.should eq("200")
  end

  it "GET blog should be successful" do
    get :blog
    response.code.should eq("200")
  end

  it "GET contact-us should be successful" do
    get :contact_us
    response.code.should eq("200")
  end

  it "POST message should be successful" do
    post :message, :message => {'name' => 'John Doe', 'email' => 'john@doe.com', 'subject' => 'foo', 'body' => 'bar'}
    response.code.should eq("200")
  end

  it 'POST message should not be successful with empty hash' do
    post :message, :message => {}
    flash[:error].should eq('Please fill all fields and make sure they are valid.')
    response.code.should eq('200')
  end

  it 'POST message should not be successful with partially incorrect hash' do
    post :message, :message => {'name' => 'John Doe', 'email' => 'john@doe', 'subject' => 'foo', 'body' => 'bar'}
    flash[:error].should eq('Please fill all fields and make sure they are valid.')
    response.code.should eq('200')
  end
end

