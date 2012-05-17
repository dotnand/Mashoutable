require 'spec_helper'

describe UserHashtagsController do
  before(:each) do
    @user = FactoryGirl.create(:user)
    @user_hashtag = FactoryGirl.create(:user_hashtag, :user => @user)
    controller.stub!(:current_user).and_return(@user)
  end

  describe "POST 'create'" do
    it "returns http success" do
      post 'create'
      response.should be_success
    end

    describe "with valid parameters" do
      it 'should create a new hashtag' do
        expect {
          post :create, :user_hashtag => { :tag => '#hashtag' }
        }.to change(UserHashtag, :count).by(1)
      end
    end
  end

  describe "PUT 'update'" do
    it "returns http success" do
      put :update, :id => @user_hashtag.id, :user_hashtag => {}
      response.should be_success
    end

    describe "with valid params" do
      it 'should update the hashtag' do
        put :update, :id => @user_hashtag.id, :user_hashtag => { :tag => '#newhashtag' }
        @user_hashtag.reload
        @user_hashtag.tag.should == "#newhashtag"
      end
    end

    describe 'with invalid params' do
      it 'should not update the hashtag' do
        tag = @user_hashtag.tag
        put :update, :id => @user_hashtag.id, :user_hashtag => { :tag => 'new#hashtag' }
        @user_hashtag.reload
        @user_hashtag.tag.should == tag
      end
    end
  end

  describe "DELETE 'destroy'" do
    it "returns http success" do
      delete 'destroy', :id => @user_hashtag.id
      response.should be_success
    end

    it 'should delete the hashtag' do
      expect {
        delete :destroy, :id => @user_hashtag.id
      }.to change(UserHashtag, :count).by(-1)
    end
  end
end
