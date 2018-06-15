require_dependency "auth_hub/application_controller"

module AuthHub
  class AdminController < ApplicationController
    
    def index
        @nome_pagina = "Applicazioni"
        @errore = flash[:error]
        @successo = flash[:success]
        if @array_enti_gestiti.blank?
            @errore_configurazione = 'Non hai enti associati!'
        else
            begin
                if session['ente_corrente'].blank?
                    #errore, mostrare messaggio che l'admin deve configurare dominio
                    @errore_configurazione = "Problemi nella configurazione, l'amministratore è stato informato."
                    Mailer.with(user: @current_user, array_enti_gestiti: @array_enti_gestiti, url_gestione_utente: associa_enti_user_url(@current_user.id)).configurazione_enti_domini_principale.deliver_now
                else
                    ente_corrente = session['ente_corrente']
                    @hash_applicazioni_ente = {}
                    if ente_corrente.clienti_cliente.clienti_installazioni.length > 0
                        ente_corrente.clienti_cliente.clienti_installazioni.each{ |installazione|
                            dominio_installazione_ruby = installazione.SPIDERURL
                            dominio_installazione_hippo = installazione.HIPPO
                            if installazione.clienti_applinstallate.length > 0
                                #Uso il jwt salvato nell'user corrente alla login per fare un link e autenticarmi direttamente sulle varie applicazioni
                                # se non ce l'ha lo creo (caso in cui faccio accesso diretto su auth_hub)
                                unless current_user.jwt.blank?
                                  str_jwt_param = current_user.jwt
                                  #devo aggiungere al jwt l'ente corrente
                                  hash_jwt = JsonWebToken.decode(str_jwt_param)
                                  hash_jwt_app = hash_jwt.dup
                                else
                                  hash_jwt_app = {
                                      iss: 'soluzionipa.it',
                                      auth: 'up',
                                      user: {
                                          user_id: current_user.id,
                                          name: current_user.nome_cognome,
                                          first_name: current_user.nome,
                                          last_name: current_user.cognome,
                                          email: current_user.email,
                                          nickname: current_user.nome_cognome,
                                          admin: current_user.admin_role == true
                                      }
                                  }
                                end
                            
                            
                                installazione.clienti_applinstallate.each{ |app_installata|
                                    nome_app = app_installata.APPLICAZIONE
                                    app = AuthHub::ClientiApplicazione.find_by_NOME(nome_app)
                                    @hash_applicazioni_ente[app.ID_AREA] ||= []
                                    if app.ID_AMBIENTE == 'ruby'
                                        url_applicazione = File.join(dominio_installazione_ruby,app.URLAMMINISTRAZIONE)
                                        hash_jwt_app['dominio_ente_corrente'] = dominio_installazione_ruby
                                    elsif app.ID_AMBIENTE == 'php'
                                        url_applicazione = File.join(dominio_installazione_hippo,app.URLAMMINISTRAZIONE)
                                        hash_jwt_app['dominio_ente_corrente'] = dominio_installazione_hippo
                                    else #caso in cui non ho ambiente...
                                        url_applicazione = "#"
                                    end
                                    #se non ho http nell'url metto https
                                    url_applicazione = "https://"+url_applicazione unless url_applicazione.include?("http")
                                    #aggiungo il parametro per il jwt
                                    #creo jwt con dominio in base all'ambiente dell'applicazione corrente
                                    jwt_con_dominio = JsonWebToken.encode(hash_jwt_app)
                                    url_applicazione += ( url_applicazione.include?('?') ? "&jwt=#{jwt_con_dominio}&redirect=#{app.URLAMMINISTRAZIONE}" : "?jwt=#{jwt_con_dominio}&redirect=#{app.URLAMMINISTRAZIONE}" )
                                    @hash_applicazioni_ente[app.ID_AREA] << { nome: app.NOME, descrizione: app.DESCRIZIONE, url: url_applicazione, ambiente: app.ID_AMBIENTE}
                                }
                            end
                        }
                    else
                        @messaggio = { "warning" => "Non hai applicazioni installate nell'ente #{ente_corrente.CLIENTE}" }
                    end
                    @array_applicazioni_ente = []
                end
            rescue Exception => exc
                logger.error exc.message
                logger.error exc.backtrace.inspect
                @errore = "Problemi nella configurazione dell'ente associato." 
            end
            
            
            
        end
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
                redirect_to cambia_password_admin_path
            else
                begin
                  @current_user.password = user_params[:password]
                  @current_user.save!
                  flash[:success] = "Password Aggiornata con successo."
                  redirect_to index_admin_path
                rescue Exception => e
                  flash[:error] = e.message
                  puts e.backtrace.inspect
                  redirect_to cambia_password_admin_path
                end
            end
        else
            #vecchia password non valida
            flash[:error] = "La password corrente non è valida."
            redirect_to cambia_password_admin_path
        end
    end
    
    
    private
    
    def user_params
        params.require(:user).permit(:old_password, :password, :password_confirmation)
    end
    
    
    
    
  end
end
