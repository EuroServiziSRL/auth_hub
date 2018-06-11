module AuthHub
  class Mailer < ::ApplicationMailer
    
    
    def registrazione_eseguita
      @user = params[:user]
      mail(to: "fabianopavan84@gmail.com", subject: 'Registrato nuovo amministratore')
    end
    
    
    
    
    
  end
end
