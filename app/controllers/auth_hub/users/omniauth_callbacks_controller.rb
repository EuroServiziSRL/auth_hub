module AuthHub
  class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_before_action :authenticate_user!, only: [:azure_oauth2]
    
    #action invocata al ritorno da azure
    def azure_oauth2
      callback_from :azure_oauth2
    end
    
    #per futuri sviluppi
    # def facebook
    #   callback_from :facebook
    # end
  
    # def twitter
    #   callback_from :twitter
    # end
  
    private
  
    def callback_from(provider)
      provider = provider.to_s
      @user = User.find_for_oauth(request.env['omniauth.auth'])
      session[:user_id] = @user.id
      if @user.persisted?
        sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
        set_flash_message(:notice, :success, :kind => provider.capitalize) if is_navigational_format?
      else
        session["devise.#{provider}_data"] = request.env["omniauth.auth"]
        redirect_to new_user_session_url
      end
    end
    

    
   
    #se ci sono errori va qui, tracciare errore e rimandare a login
    def failure
      flash[:warning] = "Errore login AAD"
      redirect_to new_user_session_path
    end
  
    
  end
end