class DashboardController < ApplicationController
  layout 'dashboard'
  before_filter :current_tool
  
  def index
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
  
  def mashout
  end
  
  def blastout
  end
  
  def shoutout
  end
  
  def pickout
  end
  
  def signout
  end
  
  protected 
    def current_tool
      case(params[:action].to_sym)
        when :index then @current_tool = dashboard_path
        when :mashout then @current_tool = dashboard_mashout_path
        when :blastout then @current_tool = dashboard_blastout_path
        when :shoutout then @current_tool = dashboard_shoutout_path
        when :pickout then @current_tool = dashboard_pickout_path
        when :signout then @current_tool = dashboard_signout_path
        else @current_tool = dashboard_signout_path
      end
    end
end
