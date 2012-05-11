require 'spec_helper'

describe AdvertisementsController do

  describe "GET 'show'" do
    before(:each) do
      @ad = FactoryGirl.create(:advertisement)
    end

    it "returns http success" do
      get :show, :id => @ad.id
      response.should be_success
    end
  end

end
