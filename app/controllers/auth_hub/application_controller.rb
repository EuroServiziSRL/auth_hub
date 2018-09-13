module AuthHub
  class ApplicationController < ::ApplicationController
    before_action :authenticate_user!, except: [:new, :create, :ext_logout]
    protect_from_forgery prepend: true
    
    include Rails.application.routes.url_helpers
    
    rescue_from CanCan::AccessDenied do |exception|
      flash[:warning] = exception.message
      redirect_to auth_hub_index_path
    end
    
    #GET ext_logout DA CONTROLLARE!
    #arriva un JWT in get, controllo il ext_session_id. Redirect sul controller session per fare la logout facendo la delete delle sessioni
    #poi redirect su una ub che c'è in jwt 
    def ext_logout
      #se ho il jwt devo pulire la sessione salvata nel jwt
      unless http_get_token.blank?
          if ext_session_id_ub_in_get_token?
            auth_azure = session['auth'] == 'aad'
            #cancello dalla sessione le chiavi
            #in auth_get_token['ub_logout'] ho l'url per fare redirect
            signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
            #cancello sessioni di openweb
            session.keys.each{ |chiave_sessione|
                next if chiave_sessione == "_csrf_token"
                session.delete(chiave_sessione.to_sym)
            }
            url_per_nuova_login = "/auth_hub"+new_user_session_path
            #questa redirect fa la logout da microsoft se prima mi sono loggato con aad
            if Settings.logout_azure && auth_azure
              redirect_to "https://login.microsoftonline.com/common/oauth2/logout?post_logout_redirect_uri=#{auth_get_token['ub_logout']}"
              return
            else #se non vogliamo sloggarci da microsoft
              redirect_to auth_get_token['ub_logout']
            end
            
          else
            flash[:error] = "Non autorizzato: id sessione esterna mancante"
            redirect_to root_path
          end
      end
      return
    end
    
    
    
    #/auth_hub/cambia_ente
    def cambia_ente
      nuovo_cliente_corrente = params['cliente_id']
      ente_gestito_relation = AuthHub::EnteGestito.where(user: current_user.id, clienti_cliente: nuovo_cliente_corrente)
      unless ente_gestito_relation.blank?
        ente = ente_gestito_relation[0].clienti_cliente.CLIENTE
        session['ente_corrente'] = ente_gestito_relation[0]
        @ente_principale = session['ente_corrente']
        #traccio il cambio di ente
        ::AccessLog.debug("User #{current_user.nome} #{current_user.cognome}, #{current_user.email}, #{ente} (id: #{current_user.id}) login at #{DateTime.now} from #{current_user.current_sign_in_ip}. Superadmin: #{current_user.superadmin_role}, Admin: #{current_user.admin_role}, Admin Servizio: #{current_user.admin_servizi}")
      end
      redirect_to auth_hub.dashboard_path
    end
    
    #pagina per utente con ruolo user,
    #se admin viene fatto redirect
    def user_dashboard
        if @current_user.superadmin_role
          path = auth_hub.index_superadmin_url
        elsif @current_user.admin_role
          path = auth_hub.index_admin_url
        elsif @current_user.admin_servizi
          path = auth_hub.index_admin_url
        end
        redirect_to path unless path.blank?
    end
    
    #get per view cambia_password
    def cambia_password_admin
        @nome_pagina = "Cambia Password"
        @errore = flash[:error]
    end
    
    #post 
    def aggiorna_password
        if @current_user.valid_password?(user_params[:old_password])
            if user_params[:password] != user_params[:password_confirmation]
                flash[:error] = "Le due nuove password non coincidono."
                redirect_to auth_hub.cambia_password_admin_path
            else
                begin
                  @current_user.password = user_params[:password]
                  @current_user.save!(context: :aggiorna_password)
                  flash[:success] = "Password Aggiornata con successo."
                  redirect_to auth_hub.index_admin_path
                rescue Exception => e
                  flash[:error] = e.message
                  puts e.backtrace.inspect
                  redirect_to auth_hub.cambia_password_admin_path
                end
            end
        else
            #vecchia password non valida
            flash[:error] = "La password corrente non è valida."
            redirect_to auth_hub.cambia_password_admin_path
        end
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
        if @current_user.stato != 'confermato'
            signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
            #cancello sessioni di openweb
            if signed_out
              session.keys.each{ |chiave_sessione|
                next if chiave_sessione == "_csrf_token"
                session.delete(chiave_sessione.to_sym)
              }
              messaggio = "Utente non confermato dall'amministratore"
              redirect_to auth_hub.new_user_session_path, notice: messaggio
              return
            end
        end
        #enti_gestiti = @current_user.enti_gestiti
        enti_gestiti = @current_user.enti_gestiti.sort_by{ |ente| ente.clienti_cliente.CLIENTE}
        @array_enti_gestiti = []
        @ente_principale = session['ente_corrente']
        enti_gestiti.each do |ente|
          @ente_principale = ente if ente.principale? && @ente_principale.blank?
          #array_ente_per_select_tag = ["&#xf132; ".html_safe+ente.clienti_cliente.CLIENTE, ente.clienti_cliente.ID] #mostra uno stemmino su ogni riga
          array_ente_per_select_tag = [ente.clienti_cliente.CLIENTE, ente.clienti_cliente.ID]
          @array_enti_gestiti << array_ente_per_select_tag
        end
        #salvo in sessione per usarlo nei vari controller come user_controller
        session['array_enti_gestiti'] = @array_enti_gestiti
        #se non ho ente in sessione e non ho il principale assegnato metto il primo 
        @ente_principale = enti_gestiti[0] if enti_gestiti.length > 0 && @ente_principale.blank?
        return true
      else
        messaggio = nil
        #controllo se arrivo da form di login
        if request.post? and !params['user'].blank?
          @current_user = warden.authenticate!(:scope => :user)
          #controllo se lo stato è confermato
          if @current_user.stato == 'confermato'
            return true
          else
            signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
            #cancello sessioni di openweb
            if signed_out
              session.keys.each{ |chiave_sessione|
                next if chiave_sessione == "_csrf_token"
                session.delete(chiave_sessione.to_sym)
              }
              messaggio = "Utente non confermato dall'amministratore"
            end
          end
        end
        messaggio ||= "Si prega di accedere per vedere la pagina!"
        redirect_to auth_hub.new_user_session_path, notice: messaggio
      end
    end
        
    
    #dopo aver fatto la login arrivo a questo metodo per capire dove fare il redirect
    #QUI PASSA SEMPRE, Se sono autenticato arrivo qui senza passare per il metodo new
    def after_sign_in_path_for(user_instance)
      #controllo se ha lo stato confermato
      if user_instance.stato != 'confermato'
          signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
          #cancello sessioni di openweb
          if signed_out
            session.keys.each{ |chiave_sessione|
              next if chiave_sessione == "_csrf_token"
              session.delete(chiave_sessione.to_sym)
            }
            set_flash_message! :alert, :not_confirmed
            return auth_hub.new_user_session_path
          end
      else
       
        nome_ente = nil  #variabile permemorizzare l'ente che metto nel log accessi 
        redirect_param = "" #usata per eventuali redirect
        #controllo se mi arriva un NUOVO jwt mentre sono già loggato (caso login app esterna), sovrascrivo e cambio ulr back
        if !http_get_token.blank?
            #ho un jwt ma non ho l'id cliente
            unless user_id_in_get_token?
                flash[:error] = "Non autorizzato: idc mancante"
                #render json: { errors: ['Not Authenticated'] }, status: :unauthorized
                return main_app.error_dati_url
            else
                #ho un jwt corretto
                session.delete('from_civ_next') #pulisco la sessione se ero entrato con civ next
                #se ho cambiato tipo di auth devo rifare la login
                if !session['auth'].blank? && session['auth'] != auth_get_token['auth']
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
                  if Settings.logout_azure && session['auth'] == 'aad'
                    redirect_to "https://login.microsoftonline.com/common/oauth2/logout?post_logout_redirect_uri=#{url_per_nuova_login}"
                  else #se non vogliamo sloggarci da microsoft
                    return auth_hub.new_user_session_url({jwt: jwt})
                  end
                else
                  #ho il jwt con stessa auth, estraggo parametri e sovrascrivo
                  session[:url_pre_sign_in] = auth_get_token['ub']
                  session[:url_redirect] = auth_get_token['ub_redirect'] #serve per ritornare su una url portando un parametro redirect
                  session[:cliente_id] = auth_get_token['idc']
                  session[:ext_session_id] = auth_get_token['ext_session_id']
                  #metto l'auth nuova in params
                  session[:auth] = auth_get_token['auth']
                end
            end
        end
     
        #se sono già loggato e mi arriva una login da NEXT. Se ho dovuto ripassare per azure uso la var in sessione per sapere che venivo da civ_next
        if (params['auth'] == "aad" && ['notifiche_affissioni','trasparenza','servizi_online'].include?(params['app']) ) || !session['from_civ_next'].blank?
            #ARRIVO DA CIVILIA NEXT
            session['from_civ_next'] = true
            session['auth'] = "aad" #da NEXT arrivo sempre con azure
            session['dest_app_civ_next'] = params['app'] unless params['app'].blank?
            #devo caricare un jwt in tabella
            hmac_secret = Rails.application.secrets.external_auth_api_key
            ext_session = nil #session[:ext_session_id]
            payload = {
                # exp: Time.now.to_i + 60 * 60,
                # iat: Time.now.to_i,
                iss: 'soluzionipa.it',
                ext_session_id: ext_session,
                auth: 'aad',
                user: {
                    user_id: user_instance.id,
                    name: user_instance.nome_cognome,
                    first_name: user_instance.nome,
                    last_name: user_instance.cognome,
                    email: user_instance.email,
                    nickname: user_instance.nome_cognome,
                    tid: session['tid_corrente'],
                    admin: user_instance.admin_role == true,
                    admin_servizi: user_instance.admin_servizi == true
                }
            }
            token = JsonWebToken.encode(payload, hmac_secret, 'HS256')
            user_instance.jwt = token
            user_instance.jwt_created = DateTime.now
            user_instance.save
            #se ho in sessione tid_corrente ho fatto login azure
            unless session['tid_corrente'].blank?
              #carico il cliente/installazione in base al tenant id corrente salvato in sessione
              cliente_caricato = ClientiCliente.find_by tenant_azure: session['tid_corrente']
              #Nome ente per log
              nome_ente = cliente_caricato.CLIENTE
              installazione = cliente_caricato.clienti_installazioni.first
              if session['dest_app_civ_next'] == 'servizi_online'
                  raise "Url portale spider mancante" if installazione.SPIDER_PORTAL.blank? && installazione.SPIDERURL.blank?
                  dominio = installazione.SPIDERURL || ( installazione.SPIDER_PORTAL.blank? ? "" : Addressable::URI.parse(installazione.SPIDER_PORTAL).site ) 
                  path = dominio+"/"+helpers.map_funzioni_next(session['dest_app_civ_next'])
              else
                  raise "Url portale hippo mancante" if installazione.HIPPO.blank?
                  path = installazione.HIPPO+"/"+helpers.map_funzioni_next(session['dest_app_civ_next'])+"/login.php"
              end
            else
              #devo rifare login azure, potrei avere una sessione attiva ma fatta con username e password
              return user_omniauth_azure_oauth2_authorize_path('azure_oauth2')
            end
        else
            #NON ARRIVO DA CIVILIA NEXT
            session['from_civ_next'] = false
        end
        #da app esterna con azure
        if session[:auth] == 'aad' && !session['hash_azure'].blank? && session['from_civ_next'].blank?
            #recupero dalla sessione le info azure
            hash_azure = session['hash_azure']
            cliente_da_azure = ClientiCliente.find_by tenant_azure: hash_azure['tid']
            #Nome ente per log
            nome_ente = cliente_da_azure.CLIENTE
            
            # creo jwt
            hmac_secret = Rails.application.secrets.external_auth_api_key
            ext_session = session[:ext_session_id]
            payload = {
                # exp: Time.now.to_i + 60 * 60,
                # iat: Time.now.to_i,
                iss: 'soluzionipa.it',
                ext_session_id: ext_session,
                auth: 'aad',
                user: {
                    user_id: user_instance.id,
                    name: hash_azure['name'],
                    first_name: hash_azure['first_name'],
                    last_name: hash_azure['last_name'],
                    email: hash_azure['email'],
                    nickname: hash_azure['nickname'],
                    tid: hash_azure['tid'],
                    admin: user_instance.admin_role == true,
                    admin_servizi: user_instance.admin_servizi == true
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
            dominio_ente_chiamante = Addressable::URI.parse(session[:url_pre_sign_in]).site unless session[:url_pre_sign_in].blank?
            #Devo verificare se il dominio chiamante è uno di quelli collegati all'utente, se blank non l'ho trovato. Altrimenti ritorna cliente
            cliente_da_dominio = user_instance.trova_dominio_in_clienti(dominio_ente_chiamante)
            if cliente_da_dominio.blank?
              signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
              #cancello sessioni di openweb
              if signed_out
                session.keys.each{ |chiave_sessione|
                  next if chiave_sessione == "_csrf_token"
                  session.delete(chiave_sessione.to_sym)
                }
                flash[:notice] = nil #la notice sempre presente..aveva fatto la login con successo..
                set_flash_message! :alert, :domain_not_associated
                return path = auth_hub.new_user_session_path
              end
            else
                nome_ente = cliente_da_dominio
            end
            hmac_secret = Rails.application.secrets.external_auth_api_key
            ext_session = session[:ext_session_id]
            redirect_param = session[:url_redirect]
            payload = {
                # exp: Time.now.to_i + 60 * 60,
                # iat: Time.now.to_i,
                dominio_ente_corrente: dominio_ente_chiamante,
                iss: 'soluzionipa.it',
                auth: 'up',
                ext_session_id: ext_session,
                user: {
                    user_id: user_instance.id,
                    name: user_instance.nome_cognome,
                    first_name: user_instance.nome,
                    last_name: user_instance.cognome,
                    nickname: user_instance.nome_cognome,
                    email: user_instance.email,
                    admin: user_instance.admin_role == true,
                    admin_servizi: user_instance.admin_servizi == true
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
        if !session[:auth].blank? && !user_instance.jwt.blank? && !path.blank?
          path += ( !path.blank? && path.include?('?') ? "&jwt=#{user_instance.jwt}" : "?jwt=#{user_instance.jwt}" )  
        end
        #Gestione del redirect da chiamata spider
        if !redirect_param.blank? && !path.blank?
          path += ( path.include?('?') ? "&redirect=#{redirect_param}" : "?redirect=#{redirect_param}" )
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
          path = "#{Rails.configuration.url_dominio}#{path}"
        end
        if nome_ente.blank?
            unless EnteGestito.ente_principale_da_user(user_instance.id).blank?
                nome_ente = EnteGestito.ente_principale_da_user(user_instance.id)[0].clienti_cliente.CLIENTE
            else #altrimenti se ci sono enti associati seleziono il primo
                nome_ente = user_instance.enti_gestiti.first unless user_instance.enti_gestiti.blank?
            end
        end
        #Loggo l'accesso
        ::AccessLog.debug("User #{user_instance.nome} #{user_instance.cognome}, #{user_instance.email}, #{nome_ente} (id: #{user_instance.id}) login at #{DateTime.now.in_time_zone} from #{user_instance.current_sign_in_ip}. Superadmin: #{user_instance.superadmin_role}, Admin: #{user_instance.admin_role}, Admin Servizio: #{user_instance.admin_servizi}")
        
      end
      return path
    end
    
    #dopo logout microsoft
    # def after_sign_out_path_for(user_instance)
    #   redirect_to root_path
    # end
    
    def user_params
        params.require(:user).permit(:old_password, :password, :password_confirmation)
    end
   
   
  end
end
