require 'spec_helper'

describe TweetEmitter do
  let!(:user)         { mock('user') }  
  let(:twitter)       { mock('twitter') }
  let(:facebook)      { mock('facebook') }
  let(:replies)       { mock('replies') }
  let(:interactions)  { mock('interactions') }
  let(:params)        { {'mashout-network-twitter' => 'true'} }

  subject { TweetEmitter.new(user) }
  
  def build_emitter(params = {}) 
    out       = Out.new(params)
    out.user  = FactoryGirl.create(:user)
    
    TweetEmitter.new(user, out)
  end

  def should_receive_twitter_replies(who, status_ids)
    status_ids.each do |status_id|
      twitter.should_receive(:update).with(who, {:in_reply_to_status_id => status_id})
    end
  end
  
  def should_receive_create_interaction(out, targets)
    targets.each do |target|
      interactions.should_receive(:create).with(:target => target, :out => out)
    end
  end

  def setup_send(params)
    out     = params['out']
    replies = params['mashout-replies']
  
    should_receive_twitter_replies(out, replies)

    user.should_receive(:twitter).exactly(replies.count).times.and_return(twitter)
    user.should_receive(:replies).exactly(replies.count).times.and_return(replies)
    
    replies.should_receive(:find_or_create_by_status_id).exactly(3).times
  end
  
  def setup_send_content_only(params)
    user.should_receive(:twitter).and_return(twitter)
    twitter.should_receive(:update).with(params['out'])
    user.should_not_receive(:replies)
    user.should_not_receive(:interactions)
    user.should_not_receive(:mentions)
  end

  it 'should initialize' do
    TweetEmitter.new(user).should_not be_nil
  end
   
  it 'should post to twitter' do
    subject = build_emitter(params.merge!({'out' => 'foobar'}))
  
    user.should_receive(:twitter).and_return(twitter)
    twitter.should_receive(:update).with('foobar')
    
    subject.twitter_post
  end
   
  it 'should post to twitter with replies' do
    subject = build_emitter(params.merge!({'out' => 'hello!', 'mashout-replies' => ['1', '2', '3']}))
  
    user.should_receive(:twitter).exactly(3).times.and_return(twitter)
    3.times {|n| twitter.should_receive(:update).with('hello!', :in_reply_to_status_id => (n + 1).to_s) }
    
    subject.twitter_post
  end
   
  it 'should post to facebook' do
    subject = build_emitter(params.merge!({'out' => 'foobar', 'mashout-network-facebook' => 'true'}))
  
    user.should_receive(:facebook).and_return(facebook)
    facebook.should_receive(:feed!).with({:message => 'foobar'})
    
    subject.facebook_post
  end
   
  it 'should not tweet if content is blank' do
    subject = build_emitter
    
    user.should_not_receive(:twitter)
    twitter.should_not_receive(:update)
    
    subject.emit.should be_blank
  end
  
  it 'should send a tweet' do
    params['out'] = 'CNN'
    subject = build_emitter(params)

    user.should_receive(:twitter).and_return(twitter)
    twitter.should_receive(:update).with('CNN')
    user.should_receive(:save).and_return(true)
    
    subject.emit.should eq('CNN')
  end
  
  context 'networks' do
    before do
      params['out'] = 'CNN'      
    end

    def setup_network_receives(not_receive_network_type, receive_network_type, network_object) 
      user.should_not_receive(not_receive_network_type)
      user.should_receive(receive_network_type).and_return(network_object)
    end
  
    it 'should send a tweet using twitter only' do
      subject = build_emitter(params)
    
      setup_network_receives(:facebook, :twitter, twitter)
      twitter.should_receive(:update).with('CNN')
      user.should_receive(:save).and_return(true)
      
      subject.emit.should eq('CNN')
    end
    
    it 'should send a post using facebook only' do
      params.delete('mashout-network-twitter')
      params['mashout-network-facebook'] = 'true'
  
      subject = build_emitter(params)

      setup_network_receives(:twitter, :facebook, facebook)
      facebook.should_receive(:feed!).with(:message => 'CNN')
      user.should_receive(:save).and_return(true)
      
      subject.emit.should eq('CNN')
    end
    
    it 'should send a tweet and a post using both twitter and facebook' do
      params['mashout-network-facebook'] = 'true'

      subject = build_emitter(params)

      user.should_receive(:twitter)   { twitter }
      user.should_receive(:facebook)  { facebook }
  
      twitter.should_receive(:update).with('CNN')
      facebook.should_receive(:feed!).with(:message => 'CNN')
      user.should_receive(:save).and_return(true)
        
      subject.emit.should eq('CNN')
    end  
  end
  
  it 'should send a tweet with replies' do
    params.merge!({'out' => 'CNN', 'mashout-replies' => ['@1234', '5678', '@9999']})
    setup_send(params)
    subject = build_emitter(params)
    
    user.should_receive(:save).and_return(true)
    
    subject.emit.should eq('CNN')
  end
  
  context 'mentions' do
    it 'should save' do
      mentions  = mock('mentions')
      params.merge!({'out' => '@mention1 @mention2 #hashtag regular ol text'})

      subject = build_emitter(params)      

      should_receive_create_interaction(subject.out, ['@mention1', '@mention2'])   
      user.should_receive(:interactions).exactly(2).times.and_return(interactions)
      user.should_receive(:twitter).and_return(twitter)
      user.should_receive(:mentions).exactly(2).times.and_return(mentions)
      twitter.should_receive(:update).with(params['out'])
      mentions.should_receive(:find_or_create_by_who).exactly(2).times
      user.should_receive(:save).and_return(true)
      
      subject.emit.should eq(params['out'])
    end  
    
    it 'should not save' do
      params.merge!({'out' => '#hashtag regular ol text'})
      setup_send_content_only(params)
      subject = build_emitter(params)
      
      user.should_receive(:save).and_return(true)
      
      subject.emit.should eq(params['out'])
    end
  end
    
  context 'replies' do
    it 'should save' do
      params.merge!({'out' => 'My Cool Tweet', 'mashout-replies' => ['@1234', '5678', '@9999']})
      setup_send(params)
      subject = build_emitter(params)

      user.should_receive(:save).and_return(true)
            
      subject.emit.should eq(params['out'])
    end
    
    it 'should not save' do
      params.merge!({'out' => 'My Cool Tweet'})
      setup_send_content_only(params)
      subject = build_emitter(params)
      
      user.should_receive(:save).and_return(params)
      
      subject.emit.should eq(params['out'])
    end
  end
  
  context 'interactions' do
    it 'should save' do
      params.merge!({'out' => 'My Cool Tweet', 'mashout-replies' => ['@1234', '5678', '@9999']})  
      setup_send(params)
      subject = build_emitter(params)
      
      user.should_receive(:save).and_return(true)
      
      subject.emit.should eq(params['out'])
    end
    
    it 'should not save' do
      params.merge!({'out' => 'My Cool Tweet'})
      setup_send_content_only(params)
      subject = build_emitter(params)
      
      user.should_receive(:save).and_return(true)
      
      subject.emit.should eq(params['out'])
    end
  end
  
  it 'should queue a video transfer' do
    video = mock('video')
    
    params['out']                     = 'My cool tweet!'
    params['mashout-network-youtube'] = 'true'
    params['mashout-video']           = 'abc'
      
    subject = build_emitter(params)
      
    subject.out.should_receive(:video).and_return(video)
    subject.out.should_receive(:id).and_return(5)
    subject.out.should_receive(:save!).and_return(true)
    subject.out.should_receive(:youtube?).and_return(true)
    Resque.should_receive(:enqueue).with(VideoTransfer, 5)

    subject.emit
  end
end
