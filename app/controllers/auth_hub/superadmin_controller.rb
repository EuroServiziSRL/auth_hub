#require_dependency "auth_hub/application_controller"

module AuthHub
  class SuperadminController < ApplicationController
    before_action :valorizza_link_navigazione
    
    #view con vari link
    def index
      @nome_pagina = "Home"
    end
  
    def valorizza_link_navigazione
      session[:link_navigazione_utente] = []
      session[:link_navigazione_utente] << {'titolo' => 'Lista Utenti', 'url' => users_path }
      session[:link_navigazione_utente] << {'titolo' => 'Utenti Da Confermare', 'url' => utenti_da_confermare_path }
      session[:link_navigazione_utente] << {'titolo' => 'Gestione Database', 'url' => ::RailsAdmin::Engine.routes.url_helpers.dashboard_path }
      session[:link_navigazione_utente] << {'titolo' => 'Gestione Setup', 'url' => setups_path }
    end
  
  
  end
end
