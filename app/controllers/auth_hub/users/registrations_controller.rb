module AuthHub
  class Users::RegistrationsController < Devise::RegistrationsController
    before_action :configure_sign_up_params, only: [:create]
    before_action :configure_account_update_params, only: [:update]
    #non devo controllare se sono autenticato quando faccio la registrazione, altrimenti lo fa sempre
    before_action :authenticate_user!, except: [:new, :create]
  
    #GET /resource/sign_up
    def new
      @rechapta_site_key = Settings.recaptcha_site_client
      super
    end
  
    #POST /resource
    def create
      @rechapta_site_key = Settings.recaptcha_site_client
      #creo un nuovo user, uso codice del controller originario su devise
      begin
        recaptcha_body={ 
            'secret' => Settings.recaptcha_secret,
            'response' => params["g-recaptcha-response"]
        }
        verify_recaptcha = HTTParty.post('https://www.google.com/recaptcha/api/siteverify', 
            :body => recaptcha_body,
            :follow_redirects => false) 
        verify = verify_recaptcha.parsed_response
        if verify['success']
          build_resource(sign_up_params)
          #resource è un istanza di AuthHub::User
          resource.admin_role = true #li creo sempre come admin quelli che si registrano
          resource.stato = "da_validare"
          nome_e_cognome = "#{sign_up_params['nome']} #{sign_up_params['cognome']}"
          resource.nome_cognome = nome_e_cognome
          resource.nome = sign_up_params['nome']
          resource.cognome = sign_up_params['cognome']
          resource.ente = sign_up_params['ente']
          resource.telefono = sign_up_params['telefono']
          resource.save(context: :registrazione_da_utente)
          yield resource if block_given?
          if resource.persisted?
              #set_flash_message! :notice, :signed_up
              #sign_up(resource_name, resource) non lo faccio autenticare perchè ha un account da validare
              #respond_with resource, location: after_sign_up_path_for(resource)
              flash[:success] = "Registrazione andata a buon fine"
              Mailer.with(user: resource).registrazione_eseguita_admin.deliver_now
              Mailer.with(user: resource).registrazione_eseguita_utente.deliver_now
              redirect_to new_user_session_url
          else
            clean_up_passwords resource
            #set_minimum_password_length
            respond_with resource
          end
        else
          flash[:error] = "Devi cliccare su 'Non sono un robot per poter continuare'"
          clean_up_passwords resource
          #set_minimum_password_length
          respond_with resource
        end
      
      rescue Exception => e
          logger.error e.message
          logger.error e.backtrace.inspect
      end
      
      
      
    end
  
    #GET /resource/edit
    def edit
      super
    end
  
    #PUT /resource
    def update
      super
    end
  
    #DELETE /resource
    def destroy
      super
    end
  
    #GET /resource/cancel
    # Forces the session data which is usually expired after sign
    # in to be expired now. This is useful if the user wants to
    # cancel oauth signing in/up in the middle of the process,
    # removing all OAuth session data.
    def cancel
      super
    end
  
    protected
  
    #Questo metodo viene richiamato nelle action per avere dei params "permessi" e si può creare un obj di un model
    def configure_sign_up_params
      #devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute, :nome, :cognome, :email, :password, :password_confirmation,:clienti_cliente_ids]) #fatto da devise...
      #params.require(:user).permit(:nome, :cognome, :email, :password, :password_confirmation,:clienti_cliente_ids)
      devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute, :nome, :cognome, :email, :password, :password_confirmation,:ente,:telefono,:'g-recaptcha-response']) #fatto da devise...
      params.permit(:nome, :cognome, :email, :password, :password_confirmation,:ente,:telefono,:'g-recaptcha-response')
    end
  
    #If you have extra params to permit, append them to the sanitizer.
    def configure_account_update_params
      devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
    end
  
    #The path used after sign up.
    def after_sign_up_path_for(resource)
      super(resource)
    end
  
    #The path used after sign up for inactive accounts.
    def after_inactive_sign_up_path_for(resource)
      super(resource)
    end
  end
end