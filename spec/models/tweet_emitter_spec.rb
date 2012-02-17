require 'spec_helper'

describe TweetEmitter do
  let!(:user)   { mock('user') }  
  let(:twitter) { mock('twitter') }
  let(:replies) { mock('replies') }

  subject { TweetEmitter.new(user) }

  def should_receive_twitter_replies(who, status_ids)
    status_ids.each do |status_id|
      twitter.should_receive(:update).with(who, {:in_reply_to_status_id => status_id})
    end
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
    params = {'out' => 'CNN', 'mashout-replies' => ['1234', '5678', '9999']}

    user.should_receive(:replies).exactly(3).times.and_return(replies)
    replies.should_receive(:find_or_create_by_status_id).exactly(3).times
    user.should_receive(:twitter).exactly(3).times.and_return(twitter)
    should_receive_twitter_replies(params['out'], params['mashout-replies'])

    subject.emit(params).should eq('CNN')
  end
  
  context 'mentions' do
    let(:mentions) { mock('object') }
  
    before do
      user.should_receive(:twitter).and_return(twitter)
    end
  
    it 'should save' do
      params = {'out' => '@mention1 @mention2 #hashtag regular ol text'}

      user.should_receive(:mentions).exactly(2).times.and_return(mentions)
      twitter.should_receive(:update).with(params['out'])
      mentions.should_receive(:find_or_create_by_who).exactly(2).times
      
      subject.emit(params).should eq(params['out'])
    end  
    
    it 'should not save' do
      params = {'out' => '#hashtag regular ol text'}

      twitter.should_receive(:update).with(params['out'])      
      mentions.should_not_receive(:find_or_create_by_who)
      user.should_not_receive(:mentions)
      
      subject.emit(params).should eq(params['out'])
    end
  end
    
  context 'replies' do
    it 'should save' do
      params = {'out' => 'Conan OBrien', 'mashout-replies' => ['1234', '5678', '9999']}
      
      should_receive_twitter_replies(params['out'], params['mashout-replies'])
      user.should_receive(:twitter).exactly(3).times.and_return(twitter)
      user.should_receive(:replies).exactly(3).times.and_return(replies)
      replies.should_receive(:find_or_create_by_status_id).exactly(3).times
      
      subject.emit(params).should eq(params['out'])
    end
    
    it 'should not save' do
      params = {'out' => 'Conan OBrien'}
      
      user.should_receive(:twitter).and_return(twitter)
      twitter.should_receive(:update).with(params['out'])
      replies.should_not_receive(:find_or_create_by_status_id)
      user.should_not_receive(:replies)
      
      subject.emit(params).should eq(params['out'])
    end
  end
end
