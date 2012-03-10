class TweetEmitter
  def initialize(user)
    @user = user
  end

  def emit(params)
    content = params['out']
    replies = params['mashout-replies']
    
    return if content.blank?

    send(content, replies, params['mashout-network-twitter'], params['mashout-network-facebook'])
    capture_mentions(content)
    capture_replies(replies)
    capture_interactions(content)
    
    content
  end
  
  def send(content, replies, twitter_network, facebook_network)
    if twitter_network == 'true'
      if replies.present?
        replies.each { |reply_to| @user.twitter.update(content, :in_reply_to_status_id => reply_to) }
      else 
        @user.twitter.update(content)
      end
    end
    
    if facebook_network == 'true'
      @user.facebook.feed!(:message => content)
    end
  end
  
  def capture_mentions(content)
    parse_mentions(content).each { |who| @user.mentions.find_or_create_by_who(who) }
  end
  
  def capture_replies(replies)
    replies.each { |reply| @user.replies.find_or_create_by_status_id(reply) } if replies.present?
  end
  
  def capture_interactions(content)
    parse_mentions(content).each { |reply| @user.interactions.create(:content => content, :target => reply) }
  end
  
  protected
    def parse_mentions(content)
      content.split(' ').select{ |snippet| snippet =~ /@\w+/i }
    end
end
