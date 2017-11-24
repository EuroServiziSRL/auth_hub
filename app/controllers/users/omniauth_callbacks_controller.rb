class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  
  
  # def passthru
  #   debugger
  #   a=4
  #   #redirect_to "https://login.microsoftonline.com/common/oauth2/authorize"
  
  # end
  
  
  
  def azure_oauth2
    debugger
    begin
    @user = AuthHub::User.from_omniauth(request.env['omniauth.auth'])
    session[:user_id] = @user.id
    flash[:success] = "Welcome, #{@user.name}!"
    rescue
      flash[:warning] = "Errore creazione user"
      path_to_redirect = new_user_session_path
    end
    path_to_redirect ||= dashboard_path
    redirect_to path_to_redirect
  end
  
 
  #se ci sono errori va qui, tracciare errore e rimandare a login
  def failure
    debugger
    a=4
    flash[:warning] = "Errore login AAD"
    redirect_to new_user_session_path
  end

  # protected

  # The path used when OmniAuth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end
end
