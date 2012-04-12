require 'shared_context/grouped_augmented_interactions'
require 'shared_context/twitter_profiles'
require 'shared_context/twitter_besties'
require 'spec_helper'

describe User do
  include_context 'twitter profiles'
  include_context 'grouped augmented interactions'

  let!(:twitter) { mock('object') }
  
  before do
    subject.stub(:twitter) { twitter }
  end

  it { should have_many(:authorizations) }
  it { should have_many(:mentions) }
  it { should have_many(:replies) }
  it { should have_many(:besties) }
  it { should have_many(:videos) }
  it { should have_many(:interactions) }
  it { should have_many(:outs) }
  
  it 'should create a user given a hash' do
    param = {'info' => {'name' => 'jane_doe'}}
    User.should_receive('create').with(:name => param['info']['name'])
    User.create_from_hash!(param)
  end
  
  [[:twitter, 'twitter'], [:facebook, 'facebook'], [:youtube, 'google']].each do |network, network_name|
    it "should remove #{network_name} authorization" do
      user = FactoryGirl.create(:user)
      FactoryGirl.create(:authorization, :provider => network_name, :user => user)
      
      user.send(network).should be
      user.send('remove_' << network.to_s)
      user.send(network).should be_nil
    end
  end
  
  [['@mashoutable', '@MASHOUTABLE'], ['@MASHOUTABLE', '@mashoutable']].each do |screen_name1, screen_name2|
    it 'should find bestie' do
      user = FactoryGirl.create(:user)
      FactoryGirl.create(:bestie, :screen_name => screen_name1, :user => user)
      
      user.find_bestie(screen_name2).should_not be_nil
    end
  end
  
  context 'networks' do
    let(:user) { FactoryGirl.create(:user) }
  
    it 'should remove networks' do
      params = {'mashout-network-twitter'   => 'false',
                'mashout-network-facebook'  => 'false',
                'mashout-network-youtube'   => 'false'}

      FactoryGirl.create(:authorization, :provider => 'twitter', :user => user)
      FactoryGirl.create(:authorization, :provider => 'facebook', :user => user)
      FactoryGirl.create(:authorization, :provider => 'google', :user => user)
      
      [:twitter, :facebook, :youtube].each do |network|
        user.send(network).should be
      end
      
      user.remove_networks(params)
      
      [:twitter, :facebook, :youtube].each do |network|
        user.send(network).should_not be
      end
    end

    [:twitter, :facebook].each do |network|
      network_name = network.to_s
      it "should not remove #{network_name} network if only one network remains" do
        params = {"mashout-network-#{network_name}" => 'false'}
        FactoryGirl.create(:authorization, :provider => network_name, :user => user)
        user.remove_networks(params).should be_false
      end
    end
  end
  
  context 'authorization' do
    let(:twitter)   { mock('twitter') }
    let(:facebook)  { mock('facebook') }
    let(:all_auths) { mock('all_auths') }
    let(:user)      { FactoryGirl.build(:user) }
    let(:auth)      { FactoryGirl.build(:authorization) }

    before do
      all_auths.should_receive('find_by_provider').and_return(auth)
      user.should_receive('authorizations').and_return(all_auths)
    end
  
    it 'should have twitter access if a twitter user' do
      Twitter::Client.should_receive('new').and_return(twitter)
      user.twitter.should eq(twitter)
    end
    
    it 'should have facebook access if a facebook user' do
      token = 'abc123'
      
      FbGraph::User.should_receive(:me).with(token).and_return(facebook)
      auth.should_receive(:token).and_return(token)
      
      user.facebook.should eq(facebook)
    end
    
    it 'should have youtube access if a youtube user' do
      youtube = mock('youtube')
    
      ENV['YOUTUBE_CONSUMER_KEY']     = '123'
      ENV['YOUTUBE_CONSUMER_SECRET']  = '456'
      ENV['YOUTUBE_DEV_KEY']          = 'xyz'
      
      auth.should_receive(:token).and_return('888')
      auth.should_receive(:secret).and_return('999')
      youtube.should_receive(:authorize_from_access).with('888', '999')
      YouTubeIt::OAuthClient.should_receive(:new)
                            .with(:consumer_key => ENV['YOUTUBE_CONSUMER_KEY'], :consumer_secret => ENV['YOUTUBE_CONSUMER_SECRET'], :dev_key => ENV['YOUTUBE_DEV_KEY'])
                            .and_return(youtube)
      
      user.youtube.should eq(youtube)
    end
  end
  
  context 'relationships' do
    include_context 'twitter besties' 
  
    let!(:user1) { double(:id => 1, :screen_name => 'john_doe1', :verified => true) }
    let!(:user2) { double(:id => 2, :screen_name => 'jane_doe1', :verified => false) }
    let!(:user3) { double(:id => 3, :screen_name => 'jane_doe2', :verified => true) }
    
    it 'should have tweople' do
      follower_ids      = [1]
      friend_ids        = [5]
      twitter_users     = ['twitter_1', 'twitter_2', 'twitter_3', 'twitter_4', 'twitter_5']
      twitter_profiles  = [twitter_profile1, twitter_profile2, twitter_profile3, twitter_profile4, twitter_profile5]
      
      subject.should_receive(:twitter_ids).with(:follower_ids).and_return(follower_ids)
      subject.should_receive(:twitter_ids).with(:friend_ids).and_return(friend_ids)
      subject.should_receive(:scrape_twitter_public_timeline).and_return(twitter_users)
      subject.mentions.should_receive(:find).with(:all, :select => :who).and_return([double(:who => '@twitter_2')])
      subject.twitter.should_receive(:users).with(twitter_users).and_return(twitter_profiles)
      
      subject.tweople.should eq([twitter_profile3, twitter_profile4])
    end
    
    it 'should have following me' do
      follower_ids  = [3, 100, 55]
      friend_ids    = [100, 8, 9]
      
      follower_ids.should_receive(:shuffle).and_return([55, 100, 3])
      subject.should_receive(:twitter_ids).with(:follower_ids).and_return(follower_ids)
      subject.should_receive(:twitter_ids).with(:friend_ids).and_return(friend_ids)
      twitter.should_receive(:users).with([55, 3]).and_return([user1, user2, user3])
      
      subject.following_me.should eq([user1, user2, user3])
    end
    
    it 'should have tweeps' do
      follower_ids  = [3, 100, 55]
      friend_ids    = [8, 3, 99]
      
      subject.should_receive(:twitter_ids).with(:follower_ids).and_return(follower_ids)
      subject.should_receive(:twitter_ids).with(:friend_ids).and_return(friend_ids)
      twitter.should_receive(:users).with([3]).and_return([user1])
      
      subject.followed_by_i_follow.should eq([user1])
    end
    
    it 'should have I follow' do
      friend_ids    = [3, 100, 55]
      follower_ids  = [88, 55, 2]
      
      friend_ids.should_receive(:shuffle).and_return([55, 100, 3])
      subject.should_receive(:twitter_ids).with(:friend_ids).and_return(friend_ids)
      subject.should_receive(:twitter_ids).with(:follower_ids).and_return(follower_ids)
      twitter.should_receive(:users).with([100, 3]).and_return([user1, user2, user3])
      
      subject.i_follow.should eq([user1, user2, user3])
    end
    
    it 'should have twitter besties' do
      subject.should_receive(:besties).and_return([local_bestie1, local_bestie2, local_bestie3])
      twitter.should_receive(:users).with(['twitter_1', 'twitter_2', 'twitter_3']).and_return([twitter_bestie1, twitter_bestie2, twitter_bestie3])
      
      subject.twitter_besties.should eq([twitter_bestie1, twitter_bestie2, twitter_bestie3])
    end
    
    it 'should have celeb/verified followers' do
      8.times { |n| FactoryGirl.create(:verified_twitter_user, :user_id => n) }
      
      twitter_profiles  = [twitter_profile1, twitter_profile2]

      User.should_receive(:page_through_twitter_ids).with(twitter, :friend_ids, {}, 10000).and_return([2, 4])
      User.should_receive(:page_through_twitter_ids).with(twitter, :follower_ids, {}, 10000).and_return([6, 8])
      subject.twitter.should_receive(:users).with(an_instance_of Array).and_return(twitter_profiles)
      
      subject.verified.should eq(twitter_profiles)
    end
    
    it 'should have augmented interactions' do
      grouped_interactions  = {'@twitter_1' => 3, '@twitter_2' => 2}
      interactions          = mock('interactions')
      
      interactions.should_receive(:count).with(:all, :group => 'target', :order => 'id DESC').and_return(grouped_interactions)
      subject.should_receive(:interactions).and_return(interactions)
      twitter.should_receive(:users).with(['twitter_1', 'twitter_2'])
                                    .and_return([Hashie::Mash.new({:screen_name => twitter_profile1.screen_name.gsub('@', ''), :profile_image_url => twitter_profile1.profile_image_url}), 
                                                 Hashie::Mash.new({:screen_name => twitter_profile2.screen_name.gsub('@', ''), :profile_image_url => twitter_profile2.profile_image_url})])
        
      subject.grouped_augmented_interactions({:group => 'target', :order => 'id DESC'})
             .should eq([grouped_augmented_interaction1.symbolize_keys, grouped_augmented_interaction2.symbolize_keys])
    end
  end
  
  it 'should have todays mentions' do
    mention1 = double(:created_at => Date.today, :user => double(:screen_name => 'john_doe1'), :id => 1234, :in_reply_to_status_id => 9999)
    mention2 = double(:created_at => Date.today, :user => double(:screen_name => 'john_doe2'), :id => 2345, :in_reply_to_status_id => 8888)
    mention3 = double(:created_at => Date.today, :user => double(:screen_name => 'jane_doe1'), :id => 3456, :in_reply_to_status_id => 7777)
    mention4 = double(:created_at => 2.days.ago, :user => double(:screen_name => 'jane_doe2'), :id => 4567, :in_reply_to_status_id => 5555)
    
    subject.twitter.should_receive(:mentions).with(:count => 200).and_return([mention1, mention2, mention3, mention4])
    
    subject.mentioned.should eq([mention1, mention2, mention3])
  end
  
  it 'should have todays shoutouts' do
    shoutout1 = double(:user => double(:screen_name => 'john_doe1'), :text => 'Hey dude!')
    shoutout2 = double(:user => double(:screen_name => 'john_doe2'), :text => '#S/O My peeps~')
    shoutout3 = double(:user => double(:screen_name => 'jane_doe1'), :text => 'My everyones #SHOUTOUTS')
    shoutout4 = double(:user => double(:screen_name => 'jane_doe2'), :text => '#shoutout it')
    
    subject.should_receive(:mentioned).and_return([shoutout1, shoutout2, shoutout3, shoutout4])
    
    subject.shoutouts.should eq([shoutout2, shoutout3, shoutout4])
  end
  
  it 'should have todays retweets' do
    retweeters1 = [twitter_profile1, twitter_profile2]
    retweeters2 = [twitter_profile3]

    retweet1 = double(:created_at => Date.today, :id => 1, :user => double(:screen_name => 'me'), :text => 'Hey dude!')
    retweet2 = double(:created_at => Date.today, :id => 2, :user => double(:screen_name => 'me'), :text => '#S/O My peeps~')
    
    subject.twitter.should_receive(:retweets_of_me).and_return([retweet1, retweet2])
    subject.twitter.should_receive(:retweeters_of).with(1, :count => 10).and_return(retweeters1)
    subject.twitter.should_receive(:retweeters_of).with(2, :count => 10).and_return(retweeters2)
    
    subject.retweets_of_me.should eq([{:text => 'Hey dude!', :status_id => 1, :users => [twitter_profile1, twitter_profile2]}, 
                                      {:text => '#S/O My peeps~', :status_id => 2, :users => [twitter_profile3]}])
  end
  
  it 'should have a mashoutable twitter client' do
    twitter_client                = mock('twitter client')
    ENV['TWITTER_ACCESS_TOKEN']   = 'ABC'
    ENV['TWITTER_ACCESS_SECRET']  = '123'

    Twitter::Client.should_receive(:new).with({:oauth_token => "ABC", :oauth_token_secret => "123"}).and_return(twitter_client)
    
    User.mashoutable_twitter.should eq(twitter_client)
  end
end
