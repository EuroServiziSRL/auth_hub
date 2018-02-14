module AuthHub
  module ApplicationHelper
    
    #mappa i nomi dei vari provider omniauth
    def map_strategy_omniauth(provider)
      case provider
      when :azure_oauth2
        "Azure Active Directory"
      end
    end
    
    def map_funzioni_next(funzione)
      case funzione
      when "notifiche_affissioni"
        "/messi"
      when "trasparenza"
        "/benefici/admin"
      when "servizi_online"
        "/admin/portal"
      end
    end
    
  end
end
