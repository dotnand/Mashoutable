class DashboardController < ApplicationController
  layout 'dashboard'
  before_filter :current_tool, :auth_required
  
  def index
    @besties  = get_besties
    @videos   = get_videos
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
  
  def preview_mashout
    render :text => TweetBuilder.new(self.current_user).build(params)
  end
  
  def blastout
    @guid   = params['guid']
    @videos = get_videos
    
    flash[:notice] = 'Please give your video a name' if @guid.present?
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
    @videos = get_videos
    render :partial => 'videos'
  end
  
  def create_video
    name = params['name']
    guid = params['guid']
  
    if guid.blank?
      render :text => 'Video was not supplied', :status => 500 
    elsif name.blank?
      render :text => 'Please supply a name', :status => 500
    elsif Video.new(:guid => guid, :user => current_user).save
      render :text => 'Your video has been saved'
    end
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
    
    def create_out(params)
     begin
        @out    = params['out']
        @tweet  = TweetEmitter.new(self.current_user).emit(params)
        
        if @tweet.blank?
          flash[:notice] = 'Ooops, your tweet is empty!'
        else
          flash[:success] = 'Created your MASHOUT!'
        end
      rescue Exception => e
        flash[:error] = 'Unable to update your Twitter Timeline. ' << e.message
      end 
    end
    
    def render_besties
      @besties = get_besties
      render :partial => 'besties'   
    end
    
    def get_besties
      current_user.twitter_besties.sort_by{|bestie| bestie.id}.paginate(:page => page, :per_page => per_page(9))
    end
    
    def get_videos
      current_user.videos.paginate(:page => page, :per_page => per_page(4))
    end    
end
