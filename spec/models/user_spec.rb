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
  
  it 'should create a user given a hash' do
    param = {'info' => {'name' => 'jane_doe'}}
    User.should_receive('create').with(:name => param['info']['name'])
    User.create_from_hash!(param)
  end
  
  it 'should have twitter access if a twitter user' do
    twitter   = mock('object')
    all_auths = mock('object')
    user      = FactoryGirl.build(:user)
    auth      = FactoryGirl.build(:authorization)
    
    Twitter::Client.should_receive('new').and_return(twitter)
    all_auths.should_receive('find_by_provider').and_return(auth)
    user.should_receive('authorizations').and_return(all_auths)
    
    user.twitter.should eq(twitter)
  end
  
  context 'relationships' do
    include_context 'twitter besties' 
  
    let!(:user1)     { double(:id => 1, :screen_name => 'john_doe1', :verified => true) }
    let!(:user2)     { double(:id => 2, :screen_name => 'jane_doe1', :verified => false) }
    let!(:user3)     { double(:id => 3, :screen_name => 'jane_doe2', :verified => true) }
    
    context 'tweople' do  
      let!(:out_mention1)  { FactoryGirl.create(:mention, :user => subject, :who => 'john_doe1') }
      let!(:out_mention2)  { FactoryGirl.create(:mention, :user => subject, :who => 'john_doe2') }
      let!(:out_mention3)  { FactoryGirl.create(:mention, :user => subject, :who => 'john_doe3') }
      let!(:status1)   { double(:user => user1, :created_at => 1.day.ago, :source => 'android') }
      let!(:status2)   { double(:user => user2, :created_at => 2.days.ago, :source => 'web') }
      let!(:status3)   { double(:user => user3, :created_at => 3.days.ago, :source => 'web') }
      
      before do
        shuffled_statuses = mock('object')
        shuffled_statuses.should_receive(:shuffle).and_return([status1, status2, status3])
        twitter.should_receive(:home_timeline).with(:count => 1000).and_return(shuffled_statuses)
      end
      
      it 'should have two given a mention with no followers or friends' do
        mentions = double(:find => [])
        subject.stub(:twitter_ids).and_return([])
        subject.stub(:mentions).and_return(mentions)
        
        
        subject.tweople.should eq([user2, user3])
      end
    end
  
    it 'should have following me' do
      follower_ids = [3, 100, 55]
      
      follower_ids.should_receive(:shuffle).and_return([55, 100, 3])
      subject.should_receive(:twitter_ids).with(:follower_ids).and_return(follower_ids)
      twitter.should_receive(:users).with([55, 100, 3]).and_return([user1, user2, user3])
      
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
      friend_ids = [3, 100, 55]
      
      friend_ids.should_receive(:shuffle).and_return([55, 100, 3])
      subject.should_receive(:twitter_ids).with(:friend_ids).and_return(friend_ids)
      twitter.should_receive(:users).with([55, 100, 3]).and_return([user1, user2, user3])
      
      subject.i_follow.should eq([user1, user2, user3])
    end
    
    it 'should have twitter besties' do
      subject.should_receive(:besties).and_return([local_bestie1, local_bestie2, local_bestie3])
      twitter.should_receive(:users).with(['twitter_1', 'twitter_2', 'twitter_3']).and_return([twitter_bestie1, twitter_bestie2, twitter_bestie3])
      
      subject.twitter_besties.should eq([twitter_bestie1, twitter_bestie2, twitter_bestie3])
    end
    
    it 'should have celeb/verified followers' do
      follower_ids = [3, 100, 55]
      
      follower_ids.should_receive(:shuffle).and_return([100, 55, 3])
      subject.should_receive(:twitter_ids).with(:follower_ids).and_return(follower_ids)
      twitter.should_receive(:users).with([100, 55, 3]).and_return([user1, user2, user3])
      
      subject.verified(:follower_ids).should eq([user1, user3])
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
    retweet1 = double(:created_at => Date.today, :user => double(:screen_name => 'me'), :text => 'Hey dude!')
    retweet2 = double(:created_at => Date.today, :user => double(:screen_name => 'me'), :text => '#S/O My peeps~')
    retweet3 = double(:created_at => Date.today, :user => double(:screen_name => 'me'), :text => 'My everyones #SHOUTOUTS')
    retweet4 = double(:created_at => 2.days.ago, :user => double(:screen_name => 'me'), :text => '#shoutout it')
    
    subject.twitter.should_receive(:retweets_of_me).and_return([retweet1, retweet2, retweet3, retweet4])
    
    subject.retweets_of_me.should eq([retweet1, retweet2, retweet3])
  end
end
