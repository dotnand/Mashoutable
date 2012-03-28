class User < ActiveRecord::Base
  has_many :authorizations
  has_many :mentions
  has_many :replies
  has_many :besties, :class_name => 'Bestie'
  has_many :videos
  has_many :interactions
  has_many :outs
  
  def self.create_from_hash!(hash)
    create(:name => hash['info']['name'])
  end
  
  def find_bestie(bestie)
    besties.where('lower(screen_name) = ?', bestie.downcase).first
  end
  
  def twitter
    unless @twitter_client
      provider        = self.authorizations.find_by_provider('twitter')
      @twitter_client = Twitter::Client.new(:oauth_token => provider.token, :oauth_token_secret => provider.secret) rescue nil if provider.present?
    end
    
    @twitter_client
  end
  
  def remove_twitter
    remove_network('twitter')
    @twitter_client = nil
  end
  
  def remove_facebook
    remove_network('facebook')
    @facebook_client = nil
  end
  
  def remove_youtube
    remove_network('google')
    @youtube_client = nil
  end
  
  def remove_networks(params)
    has_twitter               = self.twitter.present?
    has_facebook              = self.facebook.present?
    wants_to_remove_twitter   = params['mashout-network-twitter'] == 'false'
    wants_to_remove_facebook  = params['mashout-network-facebook'] == 'false'
  
    if (has_twitter and not has_facebook and wants_to_remove_twitter) or (has_facebook and not has_twitter and wants_to_remove_facebook)
      errors[:base] = 'Must have at least Twitter or Facebook connected to use Mashoutable'
      return false
    end
    
    remove_twitter  if wants_to_remove_twitter
    remove_facebook if wants_to_remove_facebook
    remove_youtube  if params['mashout-network-youtube'] == 'false'
    
    true
  end
  
  def facebook
    unless @facebook_client
      provider          = self.authorizations.find_by_provider('facebook')
      @facebook_client  ||= FbGraph::User.me(provider.token) rescue nil if provider.present? 
    end
    
    @facebook_client
  end
  
  def youtube
    unless @youtube_client
      provider = self.authorizations.find_by_provider('google')
      if provider.present?
        @youtube_client ||= YouTubeIt::OAuthClient.new(:consumer_key    => ENV['YOUTUBE_CONSUMER_KEY'], 
                                                       :consumer_secret => ENV['YOUTUBE_CONSUMER_SECRET'], 
                                                       :dev_key         => ENV['YOUTUBE_DEV_KEY'])
        @youtube_client.authorize_from_access(provider.token, provider.secret) if @youtube_client.present?
      end
    end
    
    @youtube_client
  end
  
  def following_me
    # 1. get followers
    # 2. get friends
    # 3. remove friends from followers
    follower_ids      = twitter_ids(:follower_ids).shuffle
    friend_ids        = twitter_ids(:friend_ids).shuffle  
    following_me_ids  = follower_ids - friend_ids

    return [] if following_me_ids.count < 1

    twitter.users(following_me_ids[0..[following_me_ids.count, 15].min])
  end
  
  def followed_by_i_follow
    # 1. get followers
    # 2. get friends
    # 3. find from both where they are followers and friends (present on both lists)
    twitter_ids = twitter_ids(:follower_ids).shuffle & twitter_ids(:friend_ids).shuffle
    twitter.users(twitter_ids[0..100])
  end
  
  def i_follow
    # 1. get friends
    # 2. get followers
    # 3. remove followers from friends
    friend_ids    = twitter_ids(:friend_ids).shuffle
    follower_ids  = twitter_ids(:follower_ids).shuffle
    i_follow_ids  = friend_ids - follower_ids
    
    return [] if friend_ids.count < 1
    
    twitter.users(i_follow_ids[0..[i_follow_ids.count, 15].min])
  end
  
  def mentioned(date = Date.today)
    twitter_mentions  = twitter.mentions(:count => 200).select { |mention| mention.created_at.to_date == date }
    local_replies     = self.replies.find(:all, :select => :status_id).map { |mention| mention.status_id }

    twitter_mentions.reject do |twitter_mention| 
      local_replies.include?(twitter_mention.id.to_s) or local_replies.include?(twitter_mention.in_reply_to_status_id.to_s)
    end
  end

  def shoutouts
    mentioned.select { |mention| mention.text =~ /#s\/o|#S\/O|#shoutouts|#SHOUTOUTS|#shoutout|#SHOUTOUT/ }
  end
  
  def retweets_of_me(date = Date.today)
    todays_retweets = twitter.retweets_of_me(:count => 200).select { |status| status.created_at.to_date == date }    
    todays_retweets.map { |retweet| {:text => retweet.text, :status_id => retweet.id, :users => twitter.retweeters_of(retweet.id, :count => 10) } }
  end
  
  def verified(type = :follower_ids)
    twitter_user_ids = twitter_ids(type).shuffle + twitter_ids(:friend_ids).shuffle
    return [] if twitter_user_ids.count < 1
    verified_users = []
    twitter_user_ids.in_groups_of(100) do |twitter_user_id_group| 
      users = twitter.users(twitter_user_id_group).select { |user| user.verified }
      verified_users += users if users.any?
      Rails.logger.info verified_users.to_json + "\n\n"
    end
    verified_users
  end
  
  def twitter_besties
    local_besties = self.besties
    return self.twitter.users(local_besties.map { |bestie| bestie.screen_name.gsub('@', '') }) if local_besties.count > 0
    []
  end
  
  def grouped_augmented_interactions(params)
    local_interactions  = self.interactions.count(:all, params)
    twitter_users       = self.twitter.users(local_interactions.map { |target, count| target.gsub('@', '') }) if local_interactions.count > 0
    
    return twitter_users.map do |twitter_user| 
      {:screen_name       => '@' << twitter_user.screen_name, 
       :profile_image_url => twitter_user.profile_image_url, 
       :count             => local_interactions['@' << twitter_user.screen_name.downcase]}
    end if twitter_users.present?
    []
  end
  
  def twitter_ids(method)
    ids     = []
    cursor  = -1
    
    while (results = twitter.send(method, :cursor => cursor))
      ids = ids + results['ids']
      break if results['next_cursor'] == 0
      cursor = cursor + 1
    end
    
    ids
  end
  
  protected
    def remove_network(network_name)
      provider = self.authorizations.find_by_provider(network_name)
      provider.delete if provider.present?
    end
end
