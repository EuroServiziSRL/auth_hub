#require_dependency "auth_hub/application_controller"

module AuthHub
  class SuperadminController < ApplicationController
    before_action :valorizza_link_navigazione
    
    #view con vari link
    def index
      @nome_pagina = "Home"
      @errore = flash[:error]
      @successo = flash[:success]
      @warning = flash[:warning]
    end
  
    def valorizza_link_navigazione
      session[:link_navigazione_utente] = []
      session[:link_navigazione_utente] << {'titolo' => 'Lista Utenti', 'url' => users_path }
      session[:link_navigazione_utente] << {'titolo' => 'Utenti Da Confermare', 'url' => utenti_da_confermare_path }
      session[:link_navigazione_utente] << {'titolo' => 'Gestione Database', 'url' => ::RailsAdmin::Engine.routes.url_helpers.dashboard_path }
      session[:link_navigazione_utente] << {'titolo' => 'Gestione Setup', 'url' => setups_path }
      session[:link_navigazione_utente] << {'titolo' => 'Applicazioni Oauth2', 'url' => applicazioni_oauth2_path }
      session[:link_navigazione_utente] << {'titolo' => 'Invia Metadata Agid', 'url' => invia_metadata_agid_path, 'id' => 'metadata_agid'  }
    end
  
    #Mando un token jwt per fare autenticazione
    def applicazioni_oauth2
      #creo jwt
      hash_jwt_app = {
        'iss' => 'soluzionipa.it',
        'start' => DateTime.now.new_offset(0).strftime("%d%m%Y%H%M%S")  #datetime in formato utc all'invio
      }
      jwt_token = JsonWebToken.encode(hash_jwt_app)
      redirect_to "#{Settings.app_oauth2_url}/oauth/applications?jwt=#{jwt_token}"
    end
  

    def invia_metadata_agid
      result = ApiController._genera_zip_metadata
      if result['esito'] == 'ok'
        #ho il metadata in result['path_zip']
        Mailer.with(allegato: result['path_zip']).invia_metadata_agid.deliver_now
        redirect_to index_superadmin_path
      else

      end
    end


  end
end
