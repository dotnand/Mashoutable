class TweetEmitter
  def initialize(user)
    @user = user
  end

  def emit(params)
    content = params['out']
    replies = params['mashout-replies']
    
    return if content.blank?

    self.send(content, replies)
    self.capture_mentions(content)
    self.capture_replies(replies)
    
    content
  end
  
  def send(content, replies)
    if replies.present?
      replies.each { |reply_to| @user.twitter.update(content, :in_reply_to_status_id => reply_to) }
    else 
      @user.twitter.update(content)
    end
  end
  
  def capture_mentions(content)
    content.split(' ').select{ |snippet| snippet =~ /@\w+/i }.each { |who| @user.mentions.find_or_create_by_who(who) }
  end
  
  def capture_replies(replies)
    replies.each { |reply| @user.replies.find_or_create_by_status_id(reply) } if replies.present?
  end
end
