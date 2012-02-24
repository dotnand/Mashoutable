class ApplicationController < ActionController::Base
  before_filter :basic_authentication
  
  include ApplicationHelper
  layout 'inner'
  protect_from_forgery
  
  protected
    def current_user
      @current_user ||= User.find_by_id(session[:user_id])
    end

    def signed_in?
      !!current_user
    end

    helper_method :current_user, :signed_in?

    def current_user=(user)
      @current_user = user
      session[:user_id] = user.id
    end
    
    def page(default = 1)
      params[:page] || default
    end
    
    def per_page(default = 10)
      params[:per_page] || default
    end
    
    def basic_authentication
      http_basic_authenticate_with :name => 'mashoutable', :password => 'phlmashout11' if ENV['PROTECT_WITH_HTTP_BASIC_AUTH'].present?
    end
end
