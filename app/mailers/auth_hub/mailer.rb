module AuthHub
  class Mailer < ::ApplicationMailer
    
    
    def registrazione_eseguita
      @user = params[:user]
      mail(to: APP_CONFIG['mail_admin'], subject: 'Registrato nuovo amministratore.')
    end
    
    
    def configurazione_enti_domini_principale
      @user = params[:user]
      @array_enti_gestiti = params[:array_enti_gestiti]
      @url_gestione_utente = params[:url_gestione_utente]
      mail(to: APP_CONFIG['mail_admin'], subject: 'Problemi nella configurazione utente.')
    end
    
    
  end
end
