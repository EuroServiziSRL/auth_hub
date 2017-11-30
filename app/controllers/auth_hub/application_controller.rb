module AuthHub
  class ApplicationController < ActionController::Base
    before_action :authenticate_user!
    protect_from_forgery prepend: true
    
    private
  
    def authenticate_user!
      if user_signed_in?
        return true
      else
        redirect_to new_user_session_path, notice: "Please Login to view that page!"
      end
    end

    def current_user
      @current_user ||= User.find_by(id: session[:user_id])
      @current_user
    end
    
    #helper_method :current_user
    
    def after_sign_in_path_for(user_instance)
      # stored_location_for(resource)  cosa fa?
      path = request.env['omniauth.origin'].blank? ? dashboard_url : request.env['omniauth.origin'] 
      path
    end
    
    
  end
end
