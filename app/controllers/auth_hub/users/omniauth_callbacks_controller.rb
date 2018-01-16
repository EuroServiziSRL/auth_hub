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
      
      #se arrivo da app esterna devo creare il jwt
      
      #devo usare https://www.pluralsight.com/guides/ruby-ruby-on-rails/token-based-authentication-with-ruby-on-rails-5-api
      if session[:auth] == 'aad'
        hash_azure = request.env['omniauth.auth']
        hmac_secret = Rails.application.secrets.external_auth_api_key
        payload = {
          exp: Time.now.to_i + 60 * 60,
          iat: Time.now.to_i,
          user: {
            name: hash_azure['name'],
            first_name: hash_azure['_first_name'],
            last_name: hash_azure['last_name'],
            email: hash_azure['email'],
            nickname: hash_azure['nickname'],
            tid: hash_azure['tid'],
          }
        }
        token = JsonWebToken.encode(payload, hmac_secret, 'HS256')
        @user.jwt = token
        @user.jwt_created = DateTime.now
        @user.save
      end
      
      if @user.persisted?
        sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
        #set_flash_message(:notice, :success, :kind => provider.capitalize) if is_navigational_format? non mostro messaggio
      else
        #qui arrivo dopo essere stato autenticato per la prima volta
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