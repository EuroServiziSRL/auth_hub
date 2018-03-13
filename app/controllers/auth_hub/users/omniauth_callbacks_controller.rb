module AuthHub
  class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_before_action :authenticate_user!, only: [:azure_oauth2]
    
    include Rails.application.routes.url_helpers
    
    protect_from_forgery prepend: false
    
    #carico l'helper application
    helper AuthHub::ApplicationHelper
    
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
  
    #se ci sono errori va qui, tracciare errore e rimandare a login
    def failure
      flash[:warning] = "Errore login AAD"
      redirect_to new_user_session_path
    end
  
  
    private
  
    def callback_from(provider)
        begin
            provider = provider.to_s
            @user = User.find_for_oauth(request.env['omniauth.auth'])
            session[:user_id] = @user.id #id dell'utente nella tabella authhub::users
            #se arrivo da app esterna e non da civ_next devo creare il jwt
            hash_azure = request.env['omniauth.auth']['info']
            #salvo in sessione le info che arrivano da azure
            session['hash_azure'] = hash_azure
            #salvo il tenantid corrente
            if session['tid_corrente'] != hash_azure['tid']
                #pulisco la sessione php
                #session[:ext_session_id] = nil
            end
            session['tid_corrente'] = hash_azure['tid']
            #devo usare https://www.pluralsight.com/guides/ruby-ruby-on-rails/token-based-authentication-with-ruby-on-rails-5-api
            
            #I REDIRECT LI FACCIO TUTTI SU after_sign_in_path_for(user_instance)
          
            if @user.persisted?
                sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
                #set_flash_message(:notice, :success, :kind => provider.capitalize) if is_navigational_format? non mostro messaggio
            else
                #qui arrivo dopo essere stato autenticato per la prima volta
                session["devise.#{provider}_data"] = request.env["omniauth.auth"]
                redirect_to new_user_session_url
            end
    
        rescue Exception => exc
            logger.error exc.message
            logger.error exc.backtrace.join("\n")
            flash[:error] = "Dati mancanti: #{exc.message}"
            redirect_to error_dati_url
        end
    
    end

    
  
    
  end
end