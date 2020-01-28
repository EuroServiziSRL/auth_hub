#require_dependency "auth_hub/application_controller"

module AuthHub
  class AdminController < ApplicationController
    
    def index
        @nome_pagina = "Applicazioni"
        @errore = flash[:error]
        @successo = flash[:success]
        @warning = flash[:warning]
        
        if @array_enti_gestiti.blank?
            @errore = 'Non hai enti associati!'
        else
            begin
                ente_corrente = session['ente_corrente']
                if ente_corrente.blank?
                    #errore, mostrare messaggio che l'admin deve configurare dominio
                    @errore = "Problemi nella configurazione, l'amministratore è stato informato."
                    Mailer.with(user: @current_user, array_enti_gestiti: @array_enti_gestiti, url_gestione_utente: associa_enti_user_url(@current_user.id)).configurazione_enti_domini_principale.deliver_now
                else
                    @hash_applicazioni_ente = {}
                    if ente_corrente.clienti_cliente.clienti_installazioni.length > 0
                        ente_corrente.clienti_cliente.clienti_installazioni.each{ |installazione|
                            #qui ho l'installazione a livello di server che sarà o una ruby o php con le rispettive app
                            dominio_installazione_ruby = installazione.SPIDERURL || ( installazione.SPIDER_PORTAL.blank? ? "" : Addressable::URI.parse(installazione.SPIDER_PORTAL).site ) 
                            #tolgo slash alla fine se presente
                            dominio_installazione_ruby = dominio_installazione_ruby[0..-2] if dominio_installazione_ruby[-1] == "/"
                            dominio_installazione_hippo = installazione.HIPPO
                            dominio_installazione_hippo = dominio_installazione_hippo[0..-2] if dominio_installazione_hippo[-1] == "/"
                            #se ci sono applicazioni installate riferite a questa installazione/server
                            if installazione.clienti_applinstallate.length > 0
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
                                          admin: current_user.admin_role == true,
                                          admin_servizi: current_user.admin_servizi == true
                                      }
                                }
                                installazione.clienti_applinstallate.each{ |app_installata|
                                    next if app_installata.NON_VISIBILE #non mostro se non è visibile
                                    nome_app = app_installata.APPLICAZIONE
                                    app = AuthHub::ClientiApplicazione.find_by_NOME(nome_app)
                                    #se non ho la url di amministrazione non la mostro
                                    next if app.URLAMMINISTRAZIONE.blank?
                                    url_amministrazione = (app.URLAMMINISTRAZIONE[0] == "/" ? app.URLAMMINISTRAZIONE[1..-1] : app.URLAMMINISTRAZIONE)
                                    @hash_applicazioni_ente[app.ID_AREA] ||= []
                                    if app.ID_AMBIENTE == 'ruby'
                                        if app.NOME == 'cms'
                                            url_applicazione = "#{dominio_installazione_ruby.gsub("https","http")}/#{url_amministrazione}"#.gsub('//','/')
                                            hash_jwt_app['dominio_ente_corrente'] = dominio_installazione_ruby.gsub("https","http")
                                        else
                                            url_applicazione = "#{dominio_installazione_ruby}/#{url_amministrazione}"#.gsub('//','/')
                                            hash_jwt_app['dominio_ente_corrente'] = dominio_installazione_ruby
                                        end
                                    elsif app.ID_AMBIENTE == 'php'
                                        url_applicazione = "#{dominio_installazione_hippo}/#{url_amministrazione}"#.gsub('//','/')
                                        hash_jwt_app['dominio_ente_corrente'] = dominio_installazione_hippo
                                    else #caso in cui non ho ambiente...
                                        url_applicazione = "#"
                                    end
                                    url_applicazione = "https://"+url_applicazione unless url_applicazione.include?("http")
                                    #aggiungo il parametro per il jwt
                                    #creo jwt con dominio in base all'ambiente dell'applicazione corrente
                                    jwt_con_dominio = JsonWebToken.encode(hash_jwt_app)
                                    url_applicazione += ( url_applicazione.include?('?') ? "&jwt=#{jwt_con_dominio}&redirect=#{url_amministrazione}" : "?jwt=#{jwt_con_dominio}&redirect=#{url_amministrazione}" )
                                    @hash_applicazioni_ente[app.ID_AREA] << { nome: app.NOME, descrizione: app.DESCRIZIONE, url: url_applicazione, ambiente: app.ID_AMBIENTE}
                                }
                            end
                        }
                    end
                    @warning = "Non hai applicazioni installate nell'ente #{ente_corrente.clienti_cliente.CLIENTE.strip}" if @hash_applicazioni_ente.blank?
                    @array_applicazioni_ente = []
                end
            rescue Exception => exc
                logger.error exc.message
                logger.error exc.backtrace.inspect
                @errore = "Problemi nella configurazione dell'ente associato." 
            end
            
            
            
        end
    end
    
    # #get per view cambia_password
    # def cambia_password_admin
    #     @nome_pagina = "Cambia Password"
    #     @errore = flash[:error]
    # end
    
    # #post 
    # def aggiorna_password
    #     if @current_user.valid_password?(user_params[:old_password])
    #         if user_params[:password] != user_params[:password_confirmation]
    #             flash[:error] = "Le due nuove password non coincidono."
    #             redirect_to cambia_password_admin_path
    #         else
    #             begin
    #               @current_user.password = user_params[:password]
    #               @current_user.save!(context: :aggiorna_password)
    #               flash[:success] = "Password Aggiornata con successo."
    #               redirect_to index_admin_path
    #             rescue Exception => e
    #               flash[:error] = e.message
    #               puts e.backtrace.inspect
    #               redirect_to cambia_password_admin_path
    #             end
    #         end
    #     else
    #         #vecchia password non valida
    #         flash[:error] = "La password corrente non è valida."
    #         redirect_to cambia_password_admin_path
    #     end
    # end
    
    
    private
    
    # def user_params
    #     params.require(:user).permit(:old_password, :password, :password_confirmation)
    # end
    
    
    
    
  end
end
