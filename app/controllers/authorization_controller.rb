class AuthorizationController < ApplicationController
  def create  
    begin
      auth = request.env['omniauth.auth']
      logger.info auth.to_json
      unless @auth = Authorization.find_from_hash(auth)
        @auth = Authorization.create_from_hash(auth, current_user)
      end

      self.current_user = @auth.user
      redirect_to dashboard_path
    rescue Exception => ex
      logger.info ex.to_s
    end
  end
end
