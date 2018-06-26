require 'digest/sha1'

module AuthHub
    class Users::SessionsController < Devise::SessionsController
        # before_action :configure_sign_in_params, only: [:create]
        skip_before_action :authenticate_user!, only: [:new, :destroy]
        prepend_before_action :allow_params_authentication!, only: :create
        #prepend_before_action(only: [:create, :destroy]) { request.env["devise.skip_timeout"] = true }
        
        #carico l'helper application
        helper AuthHub::ApplicationHelper
        
        #GET /resource/sign_in
        def new
            #uso messaggio che arriva da flash
            @success = flash['success'] unless flash.blank?
            #leggo i parametri che arrivano e vedo se invocare subito il metodo per oauth2 azure
            #Azure active directory oauth2
            begin
                #se c'è il token con il parametro idc sto facendo una richiesta con JWT
                unless http_get_token.blank?
                  unless user_id_in_get_token?
                      flash[:error] = "Non autorizzato: idc mancante"
                      #render json: { errors: ['Not Authenticated'] }, status: :unauthorized
                      return false
                  else
                    #ho il jwt, estraggo parametri
                    session.delete('from_civ_next') #pulisco la sessione se ero entrato con civ next
                    session[:url_pre_sign_in] = auth_get_token['ub']
                    session[:url_redirect] = auth_get_token['ub_redirect'] #serve per ritornare su una url portando un parametro redirect
                    session[:cliente_id] = auth_get_token['idc']
                    session[:auth] = auth_get_token['auth']
                    session[:ext_session_id] = auth_get_token['ext_session_id']
                     
                    #se non passo niente mostro tutte le auth, altrimenti quello che arriva
                    @autenticazione = auth_get_token['auth'].blank? ? "all" : auth_get_token['auth']
                    #se azure devo fare redirect se
                    if session[:auth] == "aad" #azure active directory
                      #se l'id di sessione esterna diverso faccio logout e login, se vuoto oppure non vuoto ma uguali ripasso per login
                      if !session[:ext_session_id].blank? && session[:ext_session_id] != auth_get_token['ext_session_id']
                        redirect_to "https://login.microsoftonline.com/common/oauth2/logout?post_logout_redirect_uri=#{user_omniauth_azure_oauth2_authorize_url('azure_oauth2')}"
                        return
                      else
                        redirect_to user_omniauth_azure_oauth2_authorize_path('azure_oauth2')#, state: session["omniauth.state"]
                        return
                      end
                    elsif session[:auth] == "up" #username password
                        #controllo su eventuale login esistente
                    else
                        #caso di default, da definire..
                    end
                    
                  end
                else
                  #potrebbe essere una chiamata che arriva da CiviliaNext dove non ho jwt del tipo:
                  # xx/auth_hub/sign_in?auth=aad&app=notifiche_affissioni
                  # xx/auth_hub/sign_in?auth=aad&app=trasparenza
                  # xx/auth_hub/sign_in?auth=aad&app=servizi_online
                  if params['auth'] == "aad" && ['notifiche_affissioni','trasparenza','servizi_online'].include?(params['app'])
                      #ARRIVO DA CIVILIA NEXT
                      session.delete(:url_pre_sign_in)
                      session['auth'] = params['auth']
                      session['from_civ_next'] = true
                      session['dest_app_civ_next'] = params['app']
                      redirect_to user_omniauth_azure_oauth2_authorize_url('azure_oauth2')
                      return
                  else #non ho jwt e non arrivo da next, sono andato su una pagina interna protetta 
                    session[:url_pre_sign_in] ||= request.url if params[:auth].blank? #&& action_name != 'new'
                    session['from_civ_next'] = false
                  end
                  # mostro la view
                  @autenticazione = "all"
                end
            rescue JWT::VerificationError, JWT::DecodeError => exc
                #render json: { errors: ['Not Authenticated'] }, status: :unauthorized
                flash[:error] = "Non autorizzato: #{exc.message}"
            end
          
        
            # self.resource = resource_class.new(sign_in_params)
            # store_location_for(resource, params[:redirect_to])
            super
        end
        
        # POST /resource/sign_in
        def create
            super
        end
        
        #non usato..
        def ext_sign_out
            ub_dopo_logout = session['ub_logout']
            unless ub_dopo_logout.blank?
              if session['ext_session_id_da_cancellare'] == session[:ext_session_id]
                Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
                session.keys.each{ |chiave_sessione|
                    next if chiave_sessione == "_csrf_token"
                    session.delete(chiave_sessione.to_sym)
                }
              end
              #questa redirect fa la logout da microsoft
              #if AuthHub::Engine.config.logout_azure
              if Settings.logout_azure
                redirect_to "https://login.microsoftonline.com/common/oauth2/logout?post_logout_redirect_uri=#{ub_dopo_logout}"
              else #se non vogliamo sloggarci da microsoft
                redirect_to ub_dopo_logout
              end
            else
              flash[:error] = "Non autorizzato: url back mancante"
              redirect_to root_path
            end
        end
        
        
        
        # DELETE /resource/sign_out
        #Fa la logout, ma microsoft ricorda sul browser sempre l'account corrente
        def destroy
            signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
            set_flash_message! :notice, :signed_out if signed_out
            #yield if block_given?
            #respond_to_on_destroy
            #cancello sessioni di openweb
            session.keys.each{ |chiave_sessione|
              next if chiave_sessione == "_csrf_token"
              session.delete(chiave_sessione.to_sym)
            }
            # if current_user
            #   session.keys.each{ |chiave_sessione|
            #     next if chiave_sessione == "_csrf_token"
            #     session.delete(chiave_sessione.to_sym)
            #   }
            #   #cancello la sessione creata da devise
            #   session.delete('warden.user.user.key')
            #   flash[:success] = 'See you!'
            # end
            #questa redirect fa la logout da microsoft
            if Settings.logout_azure
                redirect_to "https://login.microsoftonline.com/common/oauth2/logout?post_logout_redirect_uri=#{root_url}"
            else #se non vogliamo sloggarci da microsoft
                redirect_to auth_hub_index_path
            end
        end
  
    
        private

        # Check if there is no signed in user before doing the sign out.
        #
        # If there is no signed in user, it will set the flash message and redirect
        # to the after_sign_out path.
    
        #Questi due metodi controllano se tutta la sessione di login è stata cancellata
        def verify_signed_out_user
            if all_signed_out?
              set_flash_message! :notice, :already_signed_out
              respond_to_on_destroy
            end
        end
    
        def all_signed_out?
            users = Devise.mappings.keys.map { |s| warden.user(scope: s, run_callbacks: false) }
            #aggiunto controllo per session['user_id'] e session['session_id'] per cancellare anche la sessione aggiunta
            users.all?(&:blank?) && session['user_id'].blank? && session['session_id'].blank?
        end
    
    end
end