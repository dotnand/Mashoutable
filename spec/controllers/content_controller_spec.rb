require 'spec_helper'

describe ContentController do
  it "GET home should be successful" do
    get :home
    response.code.should eq("200")
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
end
