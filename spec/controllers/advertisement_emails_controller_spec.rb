require 'spec_helper'

describe AdvertisementEmailsController do

  describe "POST 'create'" do
    before(:each) do
      @advertisement = FactoryGirl.create(:advertisement)
    end

    describe 'with valid params' do
      it 'should create a new email' do
        expect {
          post :create, :advertisement_email => { :advertisement_id => @advertisement.id, :email => 'user@example.com' }
        }.to change(AdvertisementEmail, :count).by(1)
      end
    end

    describe 'with invalid params' do
      it 'should not create a new email' do
        expect {
          post :create, :advertisement_email => { :advertisement_id => @advertisement.id, :email => 'foo@foo' }
        }.to change(AdvertisementEmail, :count).by(0)
      end
    end
  end
end
