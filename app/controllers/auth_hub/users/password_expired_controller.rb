module AuthHub
    class Users::PasswordExpiredController < Devise::PasswordExpiredController
      
        before_action :handle_password_change #AGGIUNTA..
        skip_before_action :handle_password_change #FA CASINI
        before_action :skip_password_change, only: [:show, :update]
        #prepend_before_action :authenticate_scope!, only: [:show, :update]
        
        def show
            @errore = flash[:error]
            respond_with(resource)
        end
        
        def update
            if resource.valid_password?(resource_params[:old_password])
              if resource_params[:password] != resource_params[:password_confirmation]
                  flash[:error] = "Le due nuove password non coincidono."
                  redirect_to user_password_expired_path
              else
                  begin
                      #resource.extend(Devise::Models::DatabaseAuthenticatablePatch)
                      resource.password = resource_params[:password]
                      if resource.save!(context: :registrazione_da_utente)
                          flash[:success] = "Password Aggiornata con successo."
                          #bypass_sign_in resource, scope: scope
                          redirect_to dashboard_path
                      else
                          clean_up_passwords(resource)
                          redirect_to user_password_expired_path
                      end
                  rescue Exception => e
                      flash[:error] = e.message
                      puts e.backtrace.inspect
                      redirect_to user_password_expired_path
                  end
              end
            else
                #vecchia password non valida
                flash[:error] = "La password corrente non è valida."
                redirect_to user_password_expired_path
            end
            
        end
        
        private
        
        def skip_password_change
            return if !resource.nil? && resource.need_change_password?
            redirect_to :root
        end
        
        
        
        # lookup if an password change needed
        def handle_password_change
            return if warden.nil?
            if not devise_controller? and not ignore_password_expire? and not request.format.nil? and request.format.html?
              Devise.mappings.keys.flatten.any? do |scope|
                if signed_in?(scope) and warden.session(scope)['password_expired']
                  # re-check to avoid infinite loop if date changed after login attempt
                  if send(:"current_#{scope}").try(:need_change_password?)
                    store_location_for(scope, request.original_fullpath) if request.get?
                    redirect_for_password_change scope
                    return
                  else
                    warden.session(scope)[:password_expired] = false
                  end
                end
              end
            end
        end
        
        def resource_params
            permitted_params = [:old_password, :password, :password_confirmation]
        
            if params.respond_to?(:permit)
              params.require(resource_name).permit(*permitted_params)
            else
              params[scope].slice(*permitted_params)
            end
        end
        
        def scope
            resource_name.to_sym
        end
        
        def authenticate_scope!
            send(:"authenticate_#{resource_name}!")
            self.resource = send("current_#{resource_name}")
        end
    
    
    
    end
end