module AuthHub
  class Users::RegistrationsController < Devise::RegistrationsController
    before_action :configure_sign_up_params, only: [:create]
    before_action :configure_account_update_params, only: [:update]
    #non devo controllare se sono autenticato quando faccio la registrazione, altrimenti lo fa sempre
    skip_before_action :authenticate_user!, only: [:create]
  
    #GET /resource/sign_up
    def new
      super
    end
  
    #POST /resource
    def create
      #creo un nuovo user
      begin
        #salva anche il clienti_cliente
        nuovo_admin = AuthHub::User.new(configure_sign_up_params.to_h)
        nuovo_admin.admin_role = true #li creo sempre come admin quelli che si registrano
        nuovo_admin.save
        flash[:success] = "Registrazione andata a buon fine"
        redirect_to new_user_session_url
      rescue Exception => e
        puts e.message
        puts e.backtrace.inspect
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
      devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute, :nome, :cognome, :email, :password, :password_confirmation,:clienti_cliente_ids]) #fatto da devise...
      params.require(:user).permit(:nome, :cognome, :email, :password, :password_confirmation,:clienti_cliente_ids)
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