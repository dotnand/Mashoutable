class Out < ActiveRecord::Base
  belongs_to :user
  belongs_to :video
  has_many :hashtags, :class_name => 'OutHashtag'
  has_many :trends,   :class_name => 'OutTrend'
  has_many :targets,  :class_name => 'OutTarget'
  has_many :replies,  :class_name => 'OutReply'
  has_many :media,    :class_name => 'OutMedia'
  validates_presence_of :user
  accepts_nested_attributes_for :hashtags, :trends, :targets, :replies, :media

  def initialize(params = {})
    super map_incoming_params(params)
  end

  private
    def map_incoming_params(params)
      atts = {:content      => uri_decode(params['out']),
              :comment      => uri_decode(params['mashout-comment']),
              :target       => uri_decode(params['mashout-target-selection']),
              :trend_source => uri_decode(params['trend-source']),
              :twitter      => params['mashout-network-twitter'] == 'true',
              :facebook     => params['mashout-network-facebook'] == 'true',
              :youtube      => params['mashout-network-youtube'] == 'true',
              :pending      => params['pending']}

      atts[:hashtags_attributes]  = params['mashout-hashtag'].map {|tag| {:tag => uri_decode(tag), :out => self}} if params['mashout-hashtag'].present?
      atts[:trends_attributes]    = params['mashout-trend'].map {|trend| {:trend => uri_decode(trend), :out => self}} if params['mashout-trend'].present?
      atts[:replies_attributes]   = params['mashout-replies'].map {|reply| {:reply => uri_decode(reply), :out => self}} if params['mashout-replies'].present?
      atts[:targets_attributes]   = params['mashout-targets'].map {|target| {:target => uri_decode(target), :out => self}} if params['mashout-targets'].present?
      atts[:media_attributes]     = params['mashout-media'].map{ |media| { :media => uri_decode(media), :out => self } } if params['mashout-media'].present?

      atts
    end

    def uri_decode(value)
      return if value.nil?
      URI.decode(value)
    end
end

