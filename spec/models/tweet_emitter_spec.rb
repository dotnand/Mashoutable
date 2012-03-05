require 'spec_helper'

describe TweetEmitter do
  let!(:user)         { mock('user') }  
  let(:twitter)       { mock('twitter') }
  let(:replies)       { mock('replies') }
  let(:interactions)  { mock('interactions') }

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
    params = {'out' => 'CNN'}

    user.should_receive(:twitter).and_return(twitter)
    twitter.should_receive(:update).with('CNN')
    
    subject.emit(params).should eq('CNN')
  end
  
  it 'should send a tweet with replies' do
    params = {'out' => 'CNN', 'mashout-replies' => ['@1234', '5678', '@9999']}

    setup_send(params)

    subject.emit(params).should eq('CNN')
  end
  
  context 'mentions' do
    it 'should save' do
      mentions  = mock('mentions')
      params    = {'out' => '@mention1 @mention2 #hashtag regular ol text'}

      should_receive_create_interaction(params['out'], ['@mention1', '@mention2'])   
      user.should_receive(:interactions).exactly(2).times.and_return(interactions)
      
      user.should_receive(:twitter).and_return(twitter)
      user.should_receive(:mentions).exactly(2).times.and_return(mentions)
      twitter.should_receive(:update).with(params['out'])
      mentions.should_receive(:find_or_create_by_who).exactly(2).times
      
      subject.emit(params).should eq(params['out'])
    end  
    
    it 'should not save' do
      params = {'out' => '#hashtag regular ol text'}

      setup_send_content_only(params)
      
      subject.emit(params).should eq(params['out'])
    end
  end
    
  context 'replies' do
    it 'should save' do
      params = {'out' => 'My Cool Tweet', 'mashout-replies' => ['@1234', '5678', '@9999']}
      
      setup_send(params)
      
      subject.emit(params).should eq(params['out'])
    end
    
    it 'should not save' do
      params = {'out' => 'My Cool Tweet'}
      
      setup_send_content_only(params)
      
      subject.emit(params).should eq(params['out'])
    end
  end
  
  context 'interactions' do
    it 'should save' do
      params = {'out' => 'My Cool Tweet', 'mashout-replies' => ['@1234', '5678', '@9999']}
    
      setup_send(params)
      
      subject.emit(params).should eq(params['out'])
    end
    
    it 'should not save' do
      params = {'out' => 'My Cool Tweet'}
      
      setup_send_content_only(params)
      
      subject.emit(params).should eq(params['out'])
    end
  end
end
