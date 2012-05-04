require 'spec_helper'

describe FriendsController do
  let(:current_user)  { FactoryGirl.create(:user) }
  let(:other_user)    { FactoryGirl.create(:user) }
  let(:friend)        { FactoryGirl.create(:friend, user: current_user) }
  let(:twitter)       { mock('twitter') }
  let(:twitter_user)  { mock('twitter::user') }
  let(:facebook)      { mock('facebook') }

  before do
    subject.stub(:current_user) { current_user }
    current_user.stub(:twitter) { twitter }
    current_user.stub(:facebook) { facebook }
  end

  describe "POST 'create'" do
    describe 'when the profile is protected' do
      it 'should not create a friend' do
        twitter_user.stub(:protected?).and_return(true)
        twitter_user.stub(:screen_name).and_return('test')
        current_user.twitter.stub(:follow).and_return(twitter_user)

        current_user.twitter.should_receive(:follow).with(123456)
        expect {
          post :create, { user_id: current_user.id, friend: { twitter_user_id: '123456' } }
        }.to change(Friend, :count).by(0)
      end
    end

    describe 'when the profile is not protected' do
      it 'should create a friend' do
        twitter_user.stub(:protected?).and_return(false)
        twitter_user.stub(:screen_name).and_return('test')
        current_user.twitter.stub(:follow).and_return(twitter_user)

        current_user.twitter.should_receive(:follow).with(123456)
        expect {
          post :create, { user_id: current_user.id, friend: { twitter_user_id: '123456' } }
        }.to change(Friend, :count).by(1)
      end
    end
  end

  describe "DELETE 'destroy'" do
    it 'should delete the friend' do
      current_user.twitter.stub(:unfollow).and_return(twitter_user)

      current_user.twitter.should_receive(:unfollow).with(friend.twitter_user_id)
      expect {
        delete :destroy, { user_id: current_user.id, id: friend.id }
      }.to change(Friend, :count).by(-1)
    end
  end

  it 'should require authentication for all actions' do
    subject.stub(:current_user) { nil }

    post :create, { friend: { twitter_user_id: '000000' } }
    response.should redirect_to(root_url)

    delete :destroy, { user_id: other_user.id, id: friend.id}
    response.should redirect_to(root_url)
  end

end

