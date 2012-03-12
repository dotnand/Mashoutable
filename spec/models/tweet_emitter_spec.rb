require 'spec_helper'

describe TweetEmitter do
  let!(:user)         { mock('user') }  
  let(:twitter)       { mock('twitter') }
  let(:facebook)      { mock('facebook') }
  let(:replies)       { mock('replies') }
  let(:interactions)  { mock('interactions') }
  let(:params)        { {'mashout-network-twitter' => 'true'} }

  subject { TweetEmitter.new(user) }

  def should_receive_twitter_replies(who, status_ids)
    status_ids.each do |status_id|
      twitter.should_receive(:update).with(who, {:in_reply_to_status_id => status_id})
    end
  end
  
  def should_receive_create_interaction(content, targets)
    targets.each do |target|
      interactions.should_receive(:create).with(:content => content, :target => target)
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
   
  it 'should not tweet if content is blank' do
    params = {}
    
    user.should_not_receive(:twitter)
    twitter.should_not_receive(:update)
    
    subject.emit(params).should be_blank
  end
  
  it 'should send a tweet' do
    params['out'] = 'CNN'

    user.should_receive(:twitter).and_return(twitter)
    twitter.should_receive(:update).with('CNN')
    
    subject.emit(params).should eq('CNN')
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
      setup_network_receives(:facebook, :twitter, twitter)
      twitter.should_receive(:update).with('CNN')
      
      subject.emit(params).should eq('CNN')
    end
    
    it 'should send a post using facebook only' do
      params.delete('mashout-network-twitter')
      params['mashout-network-facebook'] = 'true'

      setup_network_receives(:twitter, :facebook, facebook)
      facebook.should_receive(:feed!).with(:message => 'CNN')
      
      subject.emit(params).should eq('CNN')
    end
    
    it 'should send a tweet and a post using both twitter and facebook' do
      params['mashout-network-facebook'] = 'true'

      user.should_receive(:twitter)   { twitter }
      user.should_receive(:facebook)  { facebook }
  
      twitter.should_receive(:update).with('CNN')
      facebook.should_receive(:feed!).with(:message => 'CNN')
  
      subject.emit(params).should eq('CNN')
    end  
  end
  
  it 'should send a tweet with replies' do
    params.merge!({'out' => 'CNN', 'mashout-replies' => ['@1234', '5678', '@9999']})

    setup_send(params)

    subject.emit(params).should eq('CNN')
  end
  
  context 'mentions' do
    it 'should save' do
      mentions  = mock('mentions')
      params.merge!({'out' => '@mention1 @mention2 #hashtag regular ol text'})

      should_receive_create_interaction(params['out'], ['@mention1', '@mention2'])   
      user.should_receive(:interactions).exactly(2).times.and_return(interactions)
      
      user.should_receive(:twitter).and_return(twitter)
      user.should_receive(:mentions).exactly(2).times.and_return(mentions)
      twitter.should_receive(:update).with(params['out'])
      mentions.should_receive(:find_or_create_by_who).exactly(2).times
      
      subject.emit(params).should eq(params['out'])
    end  
    
    it 'should not save' do
      params.merge!({'out' => '#hashtag regular ol text'})

      setup_send_content_only(params)
      
      subject.emit(params).should eq(params['out'])
    end
  end
    
  context 'replies' do
    it 'should save' do
      params.merge!({'out' => 'My Cool Tweet', 'mashout-replies' => ['@1234', '5678', '@9999']})
      
      setup_send(params)
      
      subject.emit(params).should eq(params['out'])
    end
    
    it 'should not save' do
      params.merge!({'out' => 'My Cool Tweet'})
      
      setup_send_content_only(params)
      
      subject.emit(params).should eq(params['out'])
    end
  end
  
  context 'interactions' do
    it 'should save' do
      params.merge!({'out' => 'My Cool Tweet', 'mashout-replies' => ['@1234', '5678', '@9999']})  
    
      setup_send(params)
      
      subject.emit(params).should eq(params['out'])
    end
    
    it 'should not save' do
      params.merge!({'out' => 'My Cool Tweet'})
      
      setup_send_content_only(params)
      
      subject.emit(params).should eq(params['out'])
    end
  end
end
