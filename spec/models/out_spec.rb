require 'spec_helper'

describe Out do
  let(:user) { FactoryGirl.create(:user) }

  [:user, :video].map { |parent| it { should belong_to(parent) } }
  [:hashtags, :trends, :targets, :replies, :media, :out_errors].map { |children| it { should have_many(children) } }
  [:user].map { |required| it { should validate_presence_of(required) } }

  context 'should initialize and mass assign' do
    let(:params)          { {} }
    let(:param_hashtags)  { ['hashtags1', 'hashtags2', 'hashtags3'] }
    let(:param_targets)   { ['targets1', 'targets2', 'targets3'] }
    let(:param_replies)   { ['replies1', 'replies2', 'replies3'] }
    let(:param_trends)    { ['trends1', 'trends2', 'trends3'] }
    let(:param_media)     { (1..3).map{|i| "media#{i}"} }

    before do
      params['out']                       = 'content'
      params['mashout-media']             = param_media
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
      out.media.map(&:media).should eq(param_media)
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

