require 'spec_helper'

describe Out do
  let(:user) { FactoryGirl.create(:user) }

  it { should belong_to :user }
  it { should belong_to :video }
  it { should have_many :hashtags }
  it { should have_many :trends }
  it { should have_many :targets }
  it { should have_many :replies }
  it { should validate_presence_of :user }
  
  context 'should initialize and mass assign' do
    let(:params)          { {} }
    let(:param_hashtags)  { ['hashtags1', 'hashtags2', 'hashtags3'] }
    let(:param_targets)   { ['targets1', 'targets2', 'targets3'] }
    let(:param_replies)   { ['replies1', 'replies2', 'replies3'] }
    let(:param_trends)    { ['trends1', 'trends2', 'trends3'] }
    
    before do
      params['out']                       = 'content'
      params['mashout-media']             = 'media'
      params['mashout-hashtag']           = param_hashtags
      params['mashout-trend']             = param_trends
      params['mashout-comment']           = 'comment'
      params['trend-source']              = 'trend-source'
      params['mashout-target-selection']  = 'target-selection'
      params['mashout-targets']           = param_targets
      params['mashout-replies']           = param_replies
      params['mashout-network-twitter']   = 'true'
      params['mashout-network-facebook']  = 'false'
      params['mashout-network-youtube']   = 'true'
      params['pending']                   = false
    end
    
    it 'should accept params' do
      out = Out.new(params)
      
      out.user = user
      out.content.should eq('content')
      out.media.should eq('media')  
      out.hashtags.map(&:tag).should eq(param_hashtags)
      out.trend_source.should eq('trend-source')
      out.trends.map(&:trend).should eq(param_trends)
      out.comment.should eq('comment')
      out.target.should eq('target-selection')
      out.targets.map(&:target).should eq(param_targets)
      out.replies.map(&:reply).should eq(param_replies)
      out.twitter?.should eq(true)
      out.facebook?.should eq(false)
      out.youtube?.should eq(true)
      out.pending.should be_false
      out.save.should be
    end
  end
end