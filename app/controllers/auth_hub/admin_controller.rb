require_dependency "auth_hub/application_controller"

module AuthHub
  class AdminController < ApplicationController
    
    def index
      @tipo_amministratore = 'Amministratore Portale'
      if @array_enti_gestiti.blank?
        @messaggio = { "warning": "Non hai enti associati" }
      else
        # user.enti_gestiti.per_cliente(cliente.id)
        id_ente_corrente = @array_enti_gestiti[0][1] #da fare: gestione ente corrente se > 1
        ente_corrente = AuthHub::ClientiCliente.find(id_ente_corrente)
        @hash_applicazioni_ente = {}
        if ente_corrente.clienti_installazioni.length > 0
          ente_corrente.clienti_installazioni.each{ |installazione|
            dominio_installazione_ruby = installazione.SPIDERURL
            dominio_installazione_hippo = installazione.HIPPO
            if installazione.clienti_applinstallate.length > 0
              installazione.clienti_applinstallate.each{ |app_installata|
                nome_app = app_installata.APPLICAZIONE
                app = AuthHub::ClientiApplicazione.find_by_NOME(nome_app)
                @hash_applicazioni_ente[app.ID_AREA] ||= []
                if app.ID_AMBIENTE == 'ruby'
                  url_applicazione = File.join("https://",dominio_installazione_ruby,app.URLAMMINISTRAZIONE)
                elsif app.ID_AMBIENTE == 'php'
                  url_applicazione = File.join("https://",dominio_installazione_hippo,app.URLAMMINISTRAZIONE)
                else #caso in cui non ho ambiente...
                  url_applicazione = "#"
                end
                @hash_applicazioni_ente[app.ID_AREA] << { 'nome': app.NOME, 'descrizione': app.DESCRIZIONE, 'url': url_applicazione, 'ambiente': app.ID_AMBIENTE}
              }
            end
            
            
            
          }
        else
          @messaggio = { "warning": "Non hai applicazioni installate nell'ente #{ente_corrente.CLIENTE}" }
        end
        @array_applicazioni_ente = [] 
      end
      a=3
    end
    
    
  end
end
