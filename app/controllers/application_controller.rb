class ApplicationController < ActionController::Base
  include ApplicationHelper

  layout 'inner'
  protect_from_forgery

  protected
    def default_url_options
      if Rails.env.development? or Rails.env.test?
        { :host => "127.0.0.1" }
      else
        {}
      end
    end

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
end

