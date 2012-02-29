class TweetBuilder
  LIMIT = 140
  
  attr_reader :tweet

  def initialize(user, video_url = nil)
    @user       = user
    @tweet      = ''
    @parts      = []
    @video_url  = video_url
  end

  def build(params)
    @tweet = ''
    
    self.media(params['mashout-media'])
    self.hashtag(params['mashout-hashtag'])
    self.trend(params['mashout-trend'])
    self.comment(params['mashout-comment'])
    self.target(params['mashout-target'])
    self.targets(params['mashout-targets'])
    self.video(params['mashout-video'])

    @tweet.strip
  end
  
  def target(value, build = true)
    return '' if value.nil?

    targets   = nil
    profiles  = nil
    
    case value
      when 'TWEOPLE'              then @user.tweople.each { |tweople| add_to_tweet(tweople.screen_name, '@') } if build
      when 'FOLLOWER'             then @user.following_me.each { |follower| add_to_tweet(follower.screen_name, '@') }  if build
      when 'FOLLOWED_BY_I_FOLLOW' then @user.followed_by_i_follow.each { |tweep| add_to_tweet(tweep.screen_name, '@') }  if build
      when 'I_FOLLOW'             then @user.i_follow.each { |followee| add_to_tweet(followee.screen_name, '@') }  if build
      when 'TODAYS_MENTIONS'      then targets = @user.mentioned.map { |status| map_status_to_target(status) }
      when 'TODAYS_SHOUTOUTS'     then targets = @user.shoutouts.map { |status| map_status_to_target(status) }
      when 'TODAYS_RTS'           then targets = @user.retweets_of_me.map { |status| map_status_to_target(status) }
      when 'CELEB_VERIFIED'       then profiles = @user.verified.map { |verified| add_to_tweet(verified.screen_name, '@') }
      when 'BESTIES'              then profiles = @user.twitter_besties.map { |twitter_bestie| map_user_to_profile(twitter_bestie) }
      else ''
    end
    
    [targets, profiles]
  end
  
  def video(value)
    return '' if value == 'NONE' or value.nil? or @video_url.nil?
    response = Bitly::Client.shorten(@video_url.call(value))
    add_to_tweet(response['data']['url']) if @user.videos.find_by_guid(value).present? and response['status_code'] == 200
  end
  
  def targets(targets)
    options(targets)
  end
    
  def media(value)
    option(value)
  end
  
  def hashtag(tags)
    options(tags)
  end
  
  def trend(trends)
    options(trends)
  end
  
  def comment(value)
    option(value)
  end
  
  def option(value)
    return '' if value == 'NONE' or value.nil?
    part = URI.decode(value)
    if not @parts.include? (part)
      add_to_tweet(part) 
      @parts << part
    end
    @tweet
  end
  
  def options(values, prepend = '')
    return '' if values.nil?
    values.each do |value| 
      part = URI.decode(value)
      if not @parts.include? (part)
        add_to_tweet(part, prepend) 
        @parts << part
      end
    end
    @tweet
  end
  
  def add_to_tweet(string, prepend = '')
    return (@tweet << prepend << string << ' ') if (@tweet.length + string.length + 1) <= TweetBuilder::LIMIT
    @tweet
  end
  
  protected
    def map_status_to_target(status)
      {:screen_name           => '@' << status.user.screen_name, 
       :text                  => status.text,
       :created_at            => status.created_at,
       :source                => status.source,
       :profile_image_url     => status.user.profile_image_url,
       :status_id             => status.id}
    end
    
    def map_user_to_profile(user)
      {:profile_image_url => user.profile_image_url, 
       :screen_name       => '@' << user.screen_name, 
       :description       => user.description, 
       :location          => user.location} 
    end
end
