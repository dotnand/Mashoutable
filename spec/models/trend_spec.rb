require 'spec_helper'

google_trend_feed = <<END_OF_STRING
  <?xml version="1.0" encoding="UTF-8"?>
  <feed xmlns="http://www.w3.org/2005/Atom" version="1.0" xml:lang="en">
  <title type="text">Google Hot Trends</title>
  <subtitle type="text">What are people searching for on Google today?</subtitle>
  <id>http://www.google.com/trends/hottrends/atom/hourly,2007-08</id>
  <link href="http://www.google.com/trends/hottrends/atom/hourly" rel="self"/>
  <updated>2012-01-28T21:00:16Z</updated>
  <entry xmlns="http://www.w3.org/2005/Atom">
  <id>2012-01-28T21:00:16Z</id>
  <title type="text"><![CDATA[facebook ipo, one for the money, the grey, antioch, ...]]></title>
  <content type="html"><![CDATA[<ol>
  <li><span class="Mild new"><a href="http://www.google.com/trends/hottrends?q=facebook+ipo&date=2012-1-28&sa=X">facebook ipo</a></span></li>
  <li><span class="Mild down1"><a href="http://www.google.com/trends/hottrends?q=welcome+back+kotter&date=2012-1-28&sa=X">welcome back kotter</a></span></li>
  <li><span class="Mild down1"><a href="http://www.google.com/trends/hottrends?q=polar+bear+plunge&date=2012-1-28&sa=X">polar bear plunge</a></span></li>
  <li><span class="Mild down12"><a href="http://www.google.com/trends/hottrends?q=demi+moore+911+call&date=2012-1-28&sa=X">demi moore 911 call</a></span></li>
  <li><span class="Mild up4"><a href="http://www.google.com/trends/hottrends?q=super+bowl+2012&date=2012-1-28&sa=X">super bowl 2012</a></span></li>
  <li><span class="Mild up2"><a href="http://www.google.com/trends/hottrends?q=earned+income+credit&date=2012-1-28&sa=X">earned income credit</a></span></li>
  <li><span class="Mild down9"><a href="http://www.google.com/trends/hottrends?q=seabiscuit&date=2012-1-28&sa=X">seabiscuit</a></span></li>
  <li><span class="Mild up3"><a href="http://www.google.com/trends/hottrends?q=fast+times+at+ridgemont+high&date=2012-1-28&sa=X">fast times at ridgemont high</a></span></li>
  <li><span class="Mild up1"><a href="http://www.google.com/trends/hottrends?q=lovelace&date=2012-1-28&sa=X">lovelace</a></span></li>
  <li><span class="Mild up3"><a href="http://www.google.com/trends/hottrends?q=the+grey+review&date=2012-1-28&sa=X">the grey review</a></span></li>
  </ol>
  ]]></content></entry></feed>
END_OF_STRING

trendspottr_response_body = <<END_OF_STRING
{\"results\":{\"links\":[{\"value\":\"http:\\/\\/t.co\\/Gjt1qkVX\",\"weight\":2.7788178313998},{\"value\":\"http:\\/\\/t.co\\/snyjskgZ\",\"weight\":1.4431392717159},{\"value\":\"http:\\/\\/t.co\\/pH02LQmJ\",\"weight\":0.35459315564975}],\"hashtags\":[{\"value\":\"#post\",\"weight\":0.037334335720286},{\"value\":\"#video\",\"weight\":0.037334335720286},{\"value\":\"#create\",\"weight\":0.037334335720286},{\"value\":\"#record\",\"weight\":0.037334335720286},{\"value\":\"#2click\",\"weight\":0.037334335720286},{\"value\":\"#clickconstruct\",\"weight\":0.037334335720286}],\"phrases\":[{\"value\":\"easier sincerely everyone\",\"weight\":0.032273718955589},{\"value\":\"dear mashoutable thanks\",\"weight\":0.022343343892331},{\"value\":\"twitter easier sincerely\",\"weight\":0.012102644608346},{\"value\":\"making twitter easier\",\"weight\":0.011521836672213},{\"value\":\"will love this..soooo\",\"weight\":0.0073596594296579},{\"value\":\"love twitter like\",\"weight\":0.0036798297148289}],\"sources\":[{\"value\":\"@xstrology\",\"weight\":2.0996880241338},{\"value\":\"@lovequotes\",\"weight\":1.0995406162265},{\"value\":\"@friendshlp\",\"weight\":0.35459315564975}]}}
END_OF_STRING

describe Trend do  
  it 'should have Twitter trends' do
    Trend::TWITTER.should eq('Twitter')
  end
  
  it 'should have Google trends' do
    Trend::GOOGLE.should eq('Google')
  end

  it 'should retrive trends from the corresponding source' do
    user = FactoryGirl.create(:user)
    
    Trend.should_receive(:twitter).with(user, nil, nil).and_return(Object.new)
    Trend.trends(user, Trend::TWITTER).should_not be_nil
    
    Trend.should_receive(:google).and_return(Object.new)
    Trend.trends(user, Trend::GOOGLE).should_not be_nil
    
    Trend.should_receive(:trendspottr).with('mashoutable').and_return(Object.new)
    Trend.trends(user, Trend::TRENDSPOTTR, nil, nil, 'mashoutable').should_not be_nil
  end

  context 'using twitter' do
    let(:trend1) { double(:name => 'Ireland', :country => 'Ireland', :woeid => 23424803) }
    let(:trend2) { double(:name => 'United Kingdom', :country => 'United Kingdom', :woeid => 23424975) }
    let(:trend3) { double(:name => 'London', :country => 'United Kingdom', :woeid => 44418) }
    let(:trend4) { double(:name => 'Worldwide', :country => 'Worldwide', :woeid => 1234) }
    let(:trend5) { double(:name => 'York', :country => 'United Kingdom', :woeid => 44419) }
    let(:trend6) { double(:name => 'Dunbar', :country => 'Ireland', :woeid => 23424802) }
    let(:twitter) { mock('object') }
    let(:user)    { mock('object') }
    
    def setup_twitter(times = 1)
      twitter.should_receive(:trend_locations).and_return([trend1, trend2, trend3, trend4, trend5, trend6])
      user.should_receive(:twitter).exactly(times).and_return(twitter)
    end
    
    it 'should retrieve global areas' do
      setup_twitter   
      trends = Trend.twitter(user)
      trends.should eq([[trend4, trend2, trend1].map{ |trend| {:name => trend.country, :value => trend.country } }, [], []])     
    end

    it 'should retrieve locations and location specific trebds given a specific country and no region' do      
      twitter.should_receive(:local_trends).with(23424975).and_return([trend2, trend3])
      setup_twitter(2)
      
      trends = Trend.twitter(user, 'United Kingdom')
      
      trends.should eq([[trend4, trend2, trend1].map{ |trend| {:name => trend.country, :value => trend.country } },
                        [trend5, trend3].map{ |trend| {:name => trend.name, :value => trend.woeid } },
                        [trend2, trend3].map{ |trend| {:name => trend.name, :value => trend.name} }])
    end    

    context 'should retieve trends' do
      def setup_trends(local_trends_id)
        setup_twitter
        user.should_receive(:twitter).and_return(twitter)
        local_trends = [double(:name => 'trend 1'), double(:name => 'trend 2'), double(:name => 'trend 3')]
        twitter.should_receive(:local_trends).with(local_trends_id).and_return(local_trends)
      end
    
      it 'if only one region exists' do
        setup_trends(23424803)
        trends = Trend.twitter(user, 'Ireland')
        trends.should eq([[trend4, trend2, trend1].map{ |trend| {:name => trend.country, :value => trend.country } },
                          [trend6].map{ |trend| {:name => trend.name, :value => trend.woeid } }, 
                          [{:name => 'trend 1', :value => 'trend 1'}, {:name => 'trend 2', :value => 'trend 2'}, {:name => 'trend 3', :value => 'trend 3'}]])
      end
      
      it 'given a specific woeid' do
        setup_trends(23424802)
        trends = Trend.twitter(user, 'Ireland', 23424802)
        trends.should eq([[trend4, trend2, trend1].map{ |trend| {:name => trend.country, :value => trend.country } },
                          [trend6].map{ |trend| {:name => trend.name, :value => trend.woeid } }, 
                          [{:name => 'trend 1', :value => 'trend 1'}, {:name => 'trend 2', :value => 'trend 2'}, {:name => 'trend 3', :value => 'trend 3'}]])
      end
    end
  end
  
  it 'should retrieve trends from google' do  
    Kernel.should_receive('open').with('http://www.google.com/trends/hottrends/atom/hourly').and_return(google_trend_feed)
    
    trends = Trend.google
    
    trends.should have(3).items
    trends[0].should have(0).items
    trends[1].should have(0).items
    trends[2].should have(10).items
    trends[2].first.should eq({:name => 'facebook ipo', :value => 'facebook ipo'})
    trends[2].last.should eq({:name => 'the grey review', :value => 'the grey review'})
  end
  
  context 'trendspottr' do
    it 'should return empty results if query isn\'t specified' do
      Trend.trendspottr(nil).should eq([[], [], []])
    end
  
    it 'should retrieve trends from trendspottr' do
      ENV['TRENDSPOTTR_USERNAME'] = 'Mashoutable'
      ENV['TRENDSPOTTR_PASSWORD'] = 'foobar'
      
      options   = {:query => {:q => 'mashoutable'}, :basic_auth => {:username => 'Mashoutable', :password => 'foobar'}}
      response  = mock('response') 
      
      HTTParty.should_receive(:get).with('http://trendspottr.com/api/v1.1/search.php', options).and_return(response)
      response.should_receive(:body).and_return(trendspottr_response_body)
      
      trends = Trend.trendspottr('mashoutable')
      trends[0].should have(0).items
      trends[1].should have(0).items
      trends[2].should eq(["#post", "#video", "#create", "#record", "#2click", "#clickconstruct"])
    end
    
    it 'should have popular topics' do
      3.times { FactoryGirl.create(:trendspottr_topic) }
      Trend.trendspottr_popular_topics.should eq(TrendspottrTopic.select(:name).map(&:name))
    end
    
    it 'should have popular searches' do
      3.times { FactoryGirl.create(:trendspottr_search) }
      Trend.trendspottr_popular_searches.should eq(TrendspottrSearch.select(:name).map(&:name))
    end
  end
end
