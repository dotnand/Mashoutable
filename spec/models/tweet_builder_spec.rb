require 'spec_helper'

describe TweetBuilder do
  let(:user) { FactoryGirl.build(:user) }
  let(:builder) { TweetBuilder.new(user) }

  it 'should have a limit' do
    TweetBuilder::LIMIT.should be >= 140
  end
  
  it 'should add to tweet' do
    builder.add_to_tweet('foobar').should eq('foobar ')
  end
  
  it 'should not add to tweet when it will be greater than LIMIT' do
    current = '123456789 123456789 123456789 123456789 123456789 123456789 ' +
              '123456789 123456789 123456789 123456789 123456789 123456789 ' +
              '123456789'
    builder.add_to_tweet(current)
    builder.add_to_tweet('123456789 123456789 ').should have(130).items
  end
  
  it 'should prepend to a tweet' do
    builder.add_to_tweet('foo', '@').should eq('@foo ')
  end
  
  context 'build with options' do
    let(:options) { ['foo', 'bar'] }
    
    it 'should have a valid tweet' do
      builder.options(options).should eq('foo bar ')
    end
    
    it 'should have a valid tweet and prepend each' do
      builder.options(options, '@').should eq('@foo @bar ')
    end
    
    it 'should return blank if given nil' do
      builder.options(nil).should be_empty
    end
  end
  
  context 'build with one option' do
    it 'should add to tweet' do
      builder.option('foo').should eq('foo ')
    end
    
    it "should return blank if given 'NONE'" do
      builder.option('NONE').should be_empty
    end
    
    it 'should return blank if given nil' do
      builder.option(nil).should be_empty
    end
  end
  
  it 'should build with targets' do
    builder.targets(['target 1', 'target 2']).should eq('target 1 target 2 ')
  end
  
  it 'should build with a comment' do
    builder.comment('foo bar').should eq('foo bar ')
  end
  
  it 'should build with many trends' do
    builder.trend(['foo', 'bar']).should eq('foo bar ')
  end
  
  it 'should build with many hashtags' do
    builder.hashtag(['foo', 'bar']).should eq('foo bar ')
  end
  
  it 'should build with a media' do
    builder.media('foo bar').should eq('foo bar ')
  end

  context 'with a user' do
    let(:user1)   { double(:screen_name => 'john_doe1', :profile_image_url => 'http://twitter-image.twitter', :description => 'description 1', :location => 'location 1') }
    let(:user2)   { double(:screen_name => 'john_doe2', :profile_image_url => 'http://twitter-image.twitter', :description => 'description 2', :location => 'location 2') }
    let(:user3)   { double(:screen_name => 'jane_doe1', :profile_image_url => 'http://twitter-image.twitter', :description => 'description 3', :location => 'location 3') }
    let(:user4)   { double(:screen_name => 'john_doe3', :profile_image_url => 'http://twitter-image.twitter', :description => 'description 4', :location => 'location 4') }
    let(:user5)   { double(:screen_name => 'john_doe4', :profile_image_url => 'http://twitter-image.twitter', :description => 'description 5', :location => 'location 5') }
    let(:user6)   { double(:screen_name => 'jane_doe2', :profile_image_url => 'http://twitter-image.twitter', :description => 'description 6', :location => 'location 6') }
    let(:status1) { double(:user => user1, :text => 'foo', :created_at => Date.today, :source => 'web', :id => 1234) }
    let(:status2) { double(:user => user2, :text => 'bar', :created_at => Date.today, :source => 'web', :id => 2345) }
    let(:status3) { double(:user => user3, :text => 'hello world', :created_at => Date.today, :source => 'web', :id => 3456) }
    let(:status4) { double(:user => user4, :text => '#s/o', :created_at => Date.today, :source => 'web', :id => 4567) }
    let(:status5) { double(:user => user5, :text => '#SHOUTOUT', :created_at => Date.today, :source => 'web', :id => 5678) }
    let(:status6) { double(:user => user6, :text => '#S/O', :created_at => Date.today, :source => 'web', :id => 6789) }
    let(:users)   { [status1.user, status2.user, status3.user] }

    def validate_first_three_tweets(tweets)
      tweets.first[:screen_name].should eq('@john_doe1')
      tweets.first[:text].should eq('foo')
      tweets.first[:created_at].should eq(Date.today)
      tweets.first[:source].should eq('web')
      tweets.first[:profile_image_url].should eq('http://twitter-image.twitter')
      tweets.first[:status_id].should eq(1234)
      tweets.second[:screen_name].should eq('@john_doe2')
      tweets.second[:text].should eq('bar')
      tweets.second[:created_at].should eq(Date.today)
      tweets.second[:source].should eq('web')
      tweets.second[:profile_image_url].should eq('http://twitter-image.twitter')
      tweets.second[:status_id].should eq(2345)
      tweets[2][:screen_name].should eq('@jane_doe1')
      tweets[2][:text].should eq('hello world')
      tweets[2][:created_at].should eq(Date.today)
      tweets[2][:source].should eq('web')
      tweets[2][:profile_image_url].should eq('http://twitter-image.twitter')
      tweets[2][:status_id].should eq(3456)
    end

    context 'targets' do
      it 'should have TODAYS MENTIONS' do
        user.should_receive(:mentioned).and_return([status1, status2, status3])
        
        mentioned, profiles = builder.target('TODAYS_MENTIONS')
        
        validate_first_three_tweets(mentioned)
      end
      
      it 'should have TODAYS SHOUTOUTS' do
        user.should_receive(:shoutouts).and_return([status4, status5, status6])
        
        shoutouts, profiles = builder.target('TODAYS_SHOUTOUTS')
        
        shoutouts.first[:screen_name].should eq('@john_doe3')
        shoutouts.first[:text].should eq('#s/o')
        shoutouts.first[:created_at].should eq(Date.today)
        shoutouts.first[:source].should eq('web')
        shoutouts.first[:profile_image_url].should eq('http://twitter-image.twitter')
        shoutouts.first[:status_id].should eq(4567)
        shoutouts.second[:screen_name].should eq('@john_doe4')
        shoutouts.second[:text].should eq('#SHOUTOUT')
        shoutouts.second[:created_at].should eq(Date.today)
        shoutouts.second[:source].should eq('web')
        shoutouts.second[:profile_image_url].should eq('http://twitter-image.twitter')
        shoutouts.second[:status_id].should eq(5678)
        shoutouts[2][:screen_name].should eq('@jane_doe2')
        shoutouts[2][:text].should eq('#S/O')
        shoutouts[2][:created_at].should eq(Date.today)
        shoutouts[2][:source].should eq('web')
        shoutouts[2][:profile_image_url].should eq('http://twitter-image.twitter')
        shoutouts[2][:status_id].should eq(6789)
      end
      
      it 'should have TODAYS RETWEETS' do
        user.should_receive(:retweets_of_me).and_return([status1, status2, status3])
        
        retweets, profiles = builder.target('TODAYS_RTS')
        
        validate_first_three_tweets(retweets)
      end
      
      it 'should have CELEB/VERIFIED' do
        user.should_receive(:verified).and_return(users)
        
        builder.target('CELEB_VERIFIED')
        
        builder.tweet.should eq('@john_doe1 @john_doe2 @jane_doe1 ')
      end
      
      it 'should not have a target given unknown' do
        builder.target('unknown target').should eq([nil, nil])
      end
    
      it 'should build given tweople' do
        user.should_receive(:tweople).and_return(users)
        
        builder.target('TWEOPLE')
        
        builder.tweet.should eq('@john_doe1 @john_doe2 @jane_doe1 ')
      end
      
      it 'should build given followers' do
        user.should_receive(:following_me).and_return(users)
        
        builder.target('FOLLOWER')
        
        builder.tweet.should eq('@john_doe1 @john_doe2 @jane_doe1 ')
      end
      
      it 'should build given I follow and followers' do
        user.should_receive(:followed_by_i_follow).and_return(users)
        
        builder.target('FOLLOWED_BY_I_FOLLOW')
        
        builder.tweet.should eq('@john_doe1 @john_doe2 @jane_doe1 ')
      end
      
      it 'should build given I follow' do
        user.should_receive(:i_follow).and_return(users)
        
        builder.target('I_FOLLOW')
        
        builder.tweet.should eq('@john_doe1 @john_doe2 @jane_doe1 ')
      end
      
      it 'should not build given an unknown target' do
        builder.target('unknown target')
        builder.tweet.should be_empty
      end
      
      it 'should not build given nil' do
        builder.target(nil)
        builder.tweet.should be_empty
      end
      
      it 'should build given besties' do
        twitter = mock('twitter')
        
        twitter.should_receive(:users).with(['bestie1', 'bestie2', 'bestie3']).and_return(users)
        user.should_receive(:twitter).and_return(twitter)
        user.should_receive(:besties).and_return(['@bestie1', '@bestie2', '@bestie3'])
      
        besties, profiles = builder.target('BESTIES')

        profiles.should eq([{:profile_image_url => user1.profile_image_url, :screen_name => '@' << user1.screen_name, :description => user1.description, :location => user1.location},
                            {:profile_image_url => user2.profile_image_url, :screen_name => '@' << user2.screen_name, :description => user2.description, :location => user2.location},
                            {:profile_image_url => user3.profile_image_url, :screen_name => '@' << user3.screen_name, :description => user3.description, :location => user3.location},])
      end
      
      it 'should build a complex tweet' do
        params                    = {}
        params['mashout-media']   = 'media'
        params['mashout-hashtag'] = ['hashtag 1', 'hashtag 2']
        params['mashout-trend']   = ['trend 1', 'trend 2']
        params['mashout-comment'] = 'comment'
        params['mashout-target']  = 'TWEOPLE'
        params['mashout-targets'] = ['target 1', 'target 2']
        
        user.should_receive(:tweople).and_return(users)
        
        builder.build(params).should eq('media hashtag 1 hashtag 2 trend 1 trend 2 comment @john_doe1 @john_doe2 @jane_doe1 target 1 target 2')
      end
      
      it 'should not build' do
        builder.target('TWEOPLE', false).should eq([nil, nil])
        builder.tweet.should be_empty
      end
    end
  end
end
