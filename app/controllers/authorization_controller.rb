class AuthorizationController < ApplicationController
  def create  
    auth = request.env['omniauth.auth']
    unless @auth = Authorization.find_from_hash(auth)
      @auth = Authorization.create_from_hash(auth, current_user)
    end

    self.current_user = @auth.user
    self.current_user.synchronize if self.current_user.present?
    redirect_to dashboard_path
  end
  
  def failure
    @message = params['message']
  end
end
