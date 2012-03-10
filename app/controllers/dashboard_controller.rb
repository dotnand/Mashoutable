class DashboardController < ApplicationController
  layout 'dashboard'

  before_filter :current_tool
  before_filter :auth_required, :except => :video_playback
  before_filter :available_networks, :if => :signed_in?
  
  # TODO: refactor into separate controllers
  
  def index
    @besties      = get_besties
    @videos       = get_videos
    @interactions = get_interactions
  end

  def tool
    case(params['tool-selection'])
      when dashboard_mashout_path then redirect_to dashboard_mashout_path
      when dashboard_blastout_path then redirect_to dashboard_blastout_path
      when dashboard_shoutout_path then redirect_to dashboard_shoutout_path
      when dashboard_pickout_path then redirect_to dashboard_pickout_path
      when dashboard_signout_path then redirect_to dashboard_signout_path
      else redirect_to dashboard_path
    end
  end

  def targets
    @target             = params['mashout-target']
    @targets, @profiles = TweetBuilder.new(current_user).target(@target, false)
    @targets            = group_hash_by(@targets, :screen_name)

    render :partial => 'target'
  end

  def trends
    @trend_source   = params[:trend_source]
    @trend_region   = params[:trend_location]
    @trend_woeid    = params[:trend_region]

    @locations, @regions, @trends = Trend.trends(current_user, @trend_source, @trend_region, @trend_woeid)

    render :partial => 'trend'
  end

  def mashout
  end

  def create_mashout
    create_out(params)
    redirect_to dashboard_mashout_path
  end

  def create_shoutout
    create_out(params)
    redirect_to dashboard_shoutout_path
  end
  
  def create_blastout
    create_out(params)
    redirect_to dashboard_blastout_path
  end
  
  def preview_mashout
    bitly = Bitly::Client.new(video_playback_url(params['mashout-video']))
    render :text => TweetBuilder.new(self.current_user, bitly).build(params)
  end

  def blastout
    if (guid = params['guid']).present?
      video = Video.new(:guid => guid, :name => current_user.name << ' (' << guid << ')', :user => current_user)
      flash[:errors] = 'Sorry, but we are unable to save your video' if not video.save
    end
    
    @tool   = @current_tool
    @videos = get_videos
  end

  def shoutout
  end

  def pickout
  end

  def signout
    session[:user_id] = nil
    redirect_to root_path
  end

  def besties
    render_besties
  end

  def delete_bestie
    bestie = current_user.besties.find_by_screen_name(params['bestie'])

    if bestie.present?
      bestie.destroy
      @message = 'Removed ' << bestie.screen_name << ' bestie'
    else
      @message = 'Bestie ' << params['bestie'] << ' not found'
    end

    render_besties
  end

  def create_bestie
    bestie_screen_name = params['bestie']
    bestie_screen_name.insert(0, '@') if bestie_screen_name[0] != '@'

    if current_user.besties.create(:screen_name => bestie_screen_name).save
      @message = 'Bestie ' << bestie_screen_name << ' created'
    else
      @message = 'Unable to create ' << bestie_screen_name
    end

    render_besties
  end

  def videos
    render_videos
  end

  def create_video
    name  = params['name']
    guid  = params['guid']
    video = Video.new(:guid => guid, :name => name, :user => current_user)

    if guid.blank?
      message = 'Video was not supplied'
    elsif name.blank?
      message = 'Please supply a video name'
    elsif video.save
      message = nil
    elsif video.errors['guid'].count > 0
      message = 'Video has already been saved'
    elsif video.errors['name'].count > 0
      message = 'Video name already has been taken'
    end

    render :text => message
  end
  
  def update_video
    @tool   = params['source']
    guid    = params['guid']
    name    = params['name']
    message = nil
    
    if name.blank?
      message = 'Name is blank'
    elsif (video = current_user.videos.find_by_guid(guid)).present?
      video.name = name
      message = 'Unable to save' if not video.save
    end
    
    if message.present?
      render :text => message, :content_type => :text
    else
      render_videos
    end
  end
  
  def delete_video
    @tool = params['source']
    video = current_user.videos.find_by_guid(params['guid'])
    
    video.destroy if video.present?
    render_videos
  end
  
  def video_playback
    guid = params['guid']
    if guid.present?
      @video = Video.find_by_guid(guid)
      render 'video_playback'
    else 
      flash[:notice] = 'Sorry, but the video you requested was not found'
      redirect_to root_url
    end
  end
  
  def interactions
    @interactions = get_interactions
    render :partial => 'interactions'
  end
  
  protected
    def current_tool
      case params[:action].to_sym
        when :index then @current_tool = dashboard_path
        when :mashout then @current_tool = dashboard_mashout_path
        when :create_mashout then @current_tool = dashboard_mashout_path
        when :blastout then @current_tool = dashboard_blastout_path
        when :shoutout then @current_tool = dashboard_shoutout_path
        when :pickout then @current_tool = dashboard_pickout_path
        when :signout then @current_tool = dashboard_signout_path
        else @current_tool = dashboard_signout_path
      end
    end

    def auth_required
      if current_user.nil?
        flash[:error] = 'Please sign in with Twitter or Facebook'
        redirect_to root_path
      end
    end

    def available_networks
      @networks = {:twitter => current_user.twitter.present?, 
                   :facebook => current_user.facebook.present?}
    end

    def create_out(params)
     begin
        # TODO: extract into out model
        if params['mashout-network-twitter'] != 'true' and params['mashout-network-facebook'] != 'true'
          flash[:error] = 'You did not select a network'
          return flash[:success].present?
        end
     
        @out    = params['out']
        @tweet  = TweetEmitter.new(self.current_user).emit(params)
        
        if @tweet.blank? 
          flash[:notice] = 'Oops, your tweet is empty!'
        else
          flash[:success] = 'Created your MASHOUT!'
        end
      rescue Exception => e
        flash[:error] = 'Unable to your send your OUT.  ' << e.message
      end
      
      flash[:success].present?
    end

    def render_besties
      @besties = get_besties
      render :partial => 'besties'
    end

    def get_besties
      current_user.twitter_besties.sort_by{|bestie| bestie.id}.paginate(:page => page, :per_page => per_page(9))
    end

    def get_videos
      current_user.videos.order('id DESC').paginate(:page => page, :per_page => per_page(4))
    end    

    def render_videos
      @videos = get_videos
      render :partial => 'videos'
    end
    
    def get_interactions
      current_user.grouped_augmented_interactions(:group => 'target').paginate(:page => page, :per_page => per_page(8))
    end
end

