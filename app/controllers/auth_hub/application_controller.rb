module AuthHub
  class ApplicationController < ActionController::Base
    before_action :authenticate_user!
    protect_from_forgery prepend: true
    
    #GET ext_logout
    def ext_logout
      redirect_to :controller => "auth_hub/users/sessions", :action =>"destroy", '_method' =>:delete
      return
    end
    
    
    private
  
    def authenticate_user!
      if user_signed_in?
        return true
      else
        #salvo l'url di provenienza per fare la redirect dopo l'autenticazione
        session[:url_pre_sign_in] = request.url if session[:auth].blank?
        redirect_to new_user_session_path, notice: "Please Login to view that page!"
      end
    end

    def current_user
      #carico l'user da sessione con auth esterna tramite omniauth
      @current_user ||= User.find_by(id: session['warden.user.user.key'][0][0]) unless session['warden.user.user.key'].blank?
      #se non ho fatto login esterna carico id salvato (usato in sign_in omniauth e anche login con email e psw devise)
      @current_user ||= User.find_by(id: session[:user_id])
      @current_user
    end
    
    #helper_method :current_user
    
    def after_sign_in_path_for(user_instance)
      path = session[:url_pre_sign_in]
      #path = request.env['omniauth.origin'].blank? ? dashboard_url : request.env['omniauth.origin'] 
      unless session[:auth].blank?
        path += "?idc=#{session[:cliente_id]}&u=#{user_instance.email}"
      end
      path
    end
    
    #serve?
    def after_sign_out_path_for(user_instance)
      a=3
    end
    
   
  end
end
