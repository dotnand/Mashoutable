class TweetEmitter
  extend ActiveModel::Naming
  attr_reader :errors, :out
  
  def initialize(user, out = nil)
    @user   = user
    @out    = out
    @errors = ActiveModel::Errors.new(self)
  end

  def emit(out = @out)
    return if out.content.blank?
    
    @out = out
    if @out.youtube? and @out.video.present?    
      Resque.enqueue(VideoTransfer, @out.id) if (@queued_emit = @out.save!)
      return
    end
    
    send_content
  end
  
  def queued_emit?
    @queued_emit ||= false
  end
  
  def validate!
    errors[:OUT] = 'can not be empty' if @out.content.empty?
    errors[:Network] = 'must be choosen' if not (@out.twitter? or @out.facebook?)
  end
  
  def send_content(params = {})
    capture_metrics

    if @user.save
      twitter_post if @out.twitter?
      facebook_post(params) if @out.facebook?
    else
      raise StandardError.new('Unable to save content')
    end
    
    @out.content
  end

  def twitter_post
    return unless @out.twitter?
  
    if @out.replies.present?
      @user.twitter.update(@out.content, :in_reply_to_status_id => @out.replies.first.reply)
    else 
      @user.twitter.update(@out.content)
    end
  end
  
  def facebook_post(params = {}) 
    # :content => content, :link => link, :source => source, :picture => picture
    @user.facebook.feed!({:message => @out.content}.merge!(params)) if @out.facebook?
  end
  
  def capture_mentions
    parse_mentions(@out.content).each { |who| @user.mentions.find_or_create_by_who(who, :out => @out) }
  end
  
  def capture_replies
    @user.replies.find_or_create_by_status_id(@out.replies.first.reply, :out => @out) if @out.replies.present?
  end
  
  def capture_interactions
    parse_mentions(@out.content).each { |reply| @user.interactions.create(:target => reply, :out => @out) }
  end
  
  def read_attribute_for_validation(attr)
    send(attr)
  end

  def TweetEmitter.human_attribute_name(attr, options = {})
    attr
  end

  def TweetEmitter.lookup_ancestors
    [self]
  end
  
  protected
    def parse_mentions(content)
      content.split(' ').select{ |snippet| snippet =~ /@\w+/i }
    end
    
    def capture_metrics
      capture_replies
      capture_mentions
      capture_interactions
    end
end
