class AuthorizationController < ApplicationController
  def create  
    auth = request.env['omniauth.auth']
    unless @auth = Authorization.find_from_hash(auth)
      @auth = Authorization.create_from_hash(auth, current_user)
    end

    self.current_user = @auth.user
    redirect_to dashboard_path
  end
  
  def failure
    logger.error "DEBUG FAILURE #{request.env}"
    logger.error "DEBUG FAILURE #{params}" 
    
    render :json => request.to_json
  end
end
