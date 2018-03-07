

module AuthHub
  class ApplicationController < ::ApplicationController
    before_action :authenticate_user!, except: [:new]
    protect_from_forgery prepend: true
    
    include Rails.application.routes.url_helpers
    
    #GET ext_logout
    #arriva un JWT in get, controllo il ext_session_id. Redirect sul controller session per fare la logout facendo la delete delle sessioni
    #poi redirect su una ub che c'è in jwt 
    def ext_logout
      #se ho il jwt devo pulire la sessione salvata nel jwt
      unless http_get_token.blank?
          if ext_session_id_ub_in_get_token?
            #cancello dalla sessione le chiavi
            session['ext_session_id_da_cancellare'] = auth_get_token['ext_session_id']
            session['ub_logout'] = auth_get_token['ub_logout']
            redirect_to :controller => "auth_hub/users/sessions", :action =>"ext_sign_out"
          else
            flash[:error] = "Non autorizzato: id sessione esterna mancante"
            redirect_to root_path
          end
      end
      return
    end
    
    private
  
    #metodo che estrae il token jwt da prametro in get
    def http_get_token
        @http_get_token ||= params['jwt'] if params['jwt'].present?
    end
    
    def auth_get_token
      @auth_get_token ||= JsonWebToken.decode(http_get_token)
    end
  
    def user_id_in_get_token?
      http_get_token && auth_get_token && auth_get_token[:idc]
    end
    
    def ext_session_id_ub_in_get_token?
      http_get_token && auth_get_token && (!auth_get_token[:ext_session_id].blank? && !auth_get_token[:ub_logout].blank?)
    end
    
    # # Uso di JWT con parametro in header, NON USATO
    # def http_token
    #     @http_token ||= if request.headers['Authorization'].present?
    #       request.headers['Authorization'].split(' ').last
    #     end
    # end
  
    # def auth_token
    #   @auth_token ||= JsonWebToken.decode(http_token)
    # end
  
    # def user_id_in_token?
    #   http_token && auth_token && auth_token[:idc]
    # end
  
  
    #Metodo che fa l'autenticazione
    def authenticate_user!
      if user_signed_in?
        enti_gestiti = @current_user.enti_gestiti
        @array_enti_gestiti = []
        @ente_principale = nil
        enti_gestiti.each do |ente|
          @ente_principale ||= ente.clienti_cliente.ID if ente.principale?
          array_ente_per_select_tag = [ente.clienti_cliente.CLIENTE, ente.clienti_cliente.ID] 
          @array_enti_gestiti << array_ente_per_select_tag
        end
        return true
      else
        #controllo se arrivo da form di login
        if request.post? and !params['user'].blank?
          @current_user = warden.authenticate!(:scope => :user)
          return true
        end
        redirect_to new_user_session_path, notice: "Please Login to view that page!"
      end
    end
        
    

    #helper per ricavare l'utente corrente loggato
    def current_user
      #carico l'user da sessione con auth esterna tramite omniauth
      @current_user ||= User.find_by(id: session['warden.user.user.key'][0][0]) unless session['warden.user.user.key'].blank?
      #se non ho fatto login esterna carico id salvato (usato in sign_in omniauth e anche login con email e psw devise)
      @current_user ||= User.find_by(id: session[:user_id])
      @current_user
    end
    
    
    def enti_gestiti
      if @current_user.nome_cognome == 'openweb'
        @enti_gestiti = "siena"
      else
        @enti_gestiti = "milano"
      end
      @enti_gestiti
    end
    
    
    #helper_method :current_user
    
    #dopo aver fatto la login con omniauth arrivo a questo metodo per capire dove fare il redirect
    #QUI PASSA SEMPRE, Se sono autenticato arrivo qui senza passare per il metodo new
    def after_sign_in_path_for(user_instance)
      #controllo se mi arriva un NUOVO jwt mentre sono già loggato (caso login app esterna), sovrascrivo e cambio ulr back
      if !http_get_token.blank?
          #ho un jwt ma non ho l'id cliente
          unless user_id_in_get_token?
              flash[:error] = "Non autorizzato: idc mancante"
              #render json: { errors: ['Not Authenticated'] }, status: :unauthorized
              return error_dati_url
          else
              #ho un jwt corretto
              session.delete('from_civ_next') #pulisco la sessione se ero entrato con civ next
              #se ho cambiato tipo di auth devo rifare la login
              if session['auth'] != auth_get_token['auth']
                jwt = params['jwt']
                signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
                set_flash_message! :notice, :signed_out if signed_out
                #cancello sessioni di openweb
                session.keys.each{ |chiave_sessione|
                    next if chiave_sessione == "_csrf_token"
                    session.delete(chiave_sessione.to_sym)
                }
                url_per_nuova_login = new_user_session_url({jwt: jwt})
                #questa redirect fa la logout da microsoft se prima mi sono loggato con aad
                if APP_CONFIG['logout_azure'] && session['auth'] == 'aad'
                  redirect_to "https://login.microsoftonline.com/common/oauth2/logout?post_logout_redirect_uri=#{url_per_nuova_login}"
                else #se non vogliamo sloggarci da microsoft
                  return new_user_session_url({jwt: jwt})
                end
              else
                #ho il jwt con stessa auth, estraggo parametri e sovrascrivo
                session[:url_pre_sign_in] = auth_get_token['ub']
                session[:cliente_id] = auth_get_token['idc']
                session[:ext_session_id] = auth_get_token['ext_session_id']
                #metto l'auth nuova in params
                session[:auth] = auth_get_token['auth']
              end
          end
      end
    
      #se sono già loggato e mi arriva una login da NEXT. Se ho dovuto ripassare per azure uso la var in sessione per sapere che venivo da civ_next
      if params['auth'] == "aad" && ['notifiche_affissioni','trasparenza','servizi_online'].include?(params['app']) || !session['from_civ_next'].blank?
          #ARRIVO DA CIVILIA NEXT
          session['from_civ_next'] = true
          session['auth'] = "aad" #da NEXT arrivo sempre con azure
          session['dest_app_civ_next'] = params['app'] unless params['app'].blank?
          #se ho in sessione tid_corrente ho fatto login azure
          unless session['tid_corrente'].blank?
            #carico il cliente/installazione in base al tenant id corrente salvato in sessione
            cliente_caricato = ClientiCliente.find_by tenant_azure: session['tid_corrente']
            installazione = cliente_caricato.clienti_installazioni.first
            if params['app'] == 'servizi_online'
                raise "Url portale spider mancante" if installazione.SPIDER_PORTAL.blank?
                path = installazione.SPIDER_PORTAL+"/"+helpers.map_funzioni_next(session['dest_app_civ_next'])
            else
                raise "Url portale hippo mancante" if installazione.HIPPO.blank?
                path = installazione.HIPPO+"/"+helpers.map_funzioni_next(session['dest_app_civ_next'])+"/login.php"
            end
          else
            #devo rifare login azure, potrei avere una sessione attiva ma fatta con username e password
            return user_omniauth_azure_oauth2_authorize_path('azure_oauth2')
          end
      end
    
      #da app esterna con azure
      if session[:auth] == 'aad' && session['from_civ_next'].blank?
          #recupero dalla sessione le info azure
          hash_azure = session['hash_azure']
          # creo jwt
          hmac_secret = Rails.application.secrets.external_auth_api_key
          ext_session = session[:ext_session_id]
          payload = {
              # exp: Time.now.to_i + 60 * 60,
              # iat: Time.now.to_i,
              iss: 'soluzionipa.it',
              ext_session_id: ext_session,
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
          user_instance.jwt = token
          user_instance.jwt_created = DateTime.now
          user_instance.save
      end
      #da app esterna con username password
      if session[:auth] == 'up' && session['from_civ_next'].blank?
          # creo jwt
          hmac_secret = Rails.application.secrets.external_auth_api_key
          ext_session = session[:ext_session_id]
          payload = {
              # exp: Time.now.to_i + 60 * 60,
              # iat: Time.now.to_i,
              iss: 'soluzionipa.it',
              ext_session_id: ext_session,
              user: {
                  name: user_instance.nome_cognome,
                  first_name: user_instance.nome,
                  last_name: user_instance.cognome,
                  email: user_instance.email
              }
          }
          token = JsonWebToken.encode(payload, hmac_secret, 'HS256')
          user_instance.jwt = token
          user_instance.jwt_created = DateTime.now
          user_instance.save
      end
      
      #se ho una path salvata in sessione o l'ho appena salvata uso quella
      path = session[:url_pre_sign_in] unless session[:url_pre_sign_in].blank?
      session.delete(:url_pre_sign_in)
    
      #se ho settato session[:auth] vengo da una app esterna o da NEXT,
      #ripasso indietro il jwt nel redirect
      if !session[:auth].blank? and !user_instance.jwt.blank?
        path += "?jwt=#{user_instance.jwt}"
      end
      #se non ho il path controllo il ruolo dell'utente, path in base al ruolo
      if path.blank?
        if user_instance.superadmin_role
          path = index_superadmin_path
        elsif user_instance.admin_role
          path = index_admin_path
        elsif user_instance.admin_servizi
          path = index_admin_path
        else #user_role
          path = dashboard_path
        end
      end
      path
    end
    
    #dopo logout microsoft
    # def after_sign_out_path_for(user_instance)
    #   redirect_to root_path
    # end
    
    
   
   
  end
end
