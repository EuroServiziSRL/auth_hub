module AuthHub
  class Mailer < ::ApplicationMailer
    
    
    def registrazione_eseguita_admin
      @user = params[:user]
      @url_conferma = edit_user_url(@user.id)
      mail(to: Settings.mail_admin_to,from: Settings.mail_admin_from, subject: 'Registrato nuovo amministratore.')
    end
    
    
    def configurazione_enti_domini_principale
      @user = params[:user]
      @array_enti_gestiti = params[:array_enti_gestiti]
      @url_gestione_utente = params[:url_gestione_utente]
      mail(to: Settings.mail_admin, subject: 'Problemi nella configurazione utente.')
    end
    
    def registrazione_eseguita_utente
      @user = params[:user]
      mail(to: @user.email,from: Settings.mail_admin_from, subject: 'Registrazione effettuata.')
    end
    
  end
end
