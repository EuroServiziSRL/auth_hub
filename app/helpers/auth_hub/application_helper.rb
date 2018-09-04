module AuthHub
  module ApplicationHelper
    
    #mappa i nomi dei vari provider omniauth
    def map_strategy_omniauth(provider)
      case provider
      when :azure_oauth2
        "Civilia Next"
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
    
    def to_canonical(url,protocollo_presente=true)
      return nil if url.blank?
      uri = Addressable::URI.parse(url)
      uri.scheme = "http" if uri.scheme.blank?
      host = uri.host.sub(/\www\./, '') if uri.host.present?
      path = (uri.path.present? && uri.host.blank?) ? uri.path.sub(/\www\./, '') : uri.path
      if protocollo_presente
        str = uri.scheme.to_s + "://" + host.to_s + path.to_s
      else
        str = host.to_s + path.to_s
      end
      return str
    rescue Addressable::URI::InvalidURIError
      nil
    rescue URI::Error
      nil
    end
    
    
    
  end
end
