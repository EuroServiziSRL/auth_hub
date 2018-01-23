module AuthHub
  class ApplicationController < ::ApplicationController
    before_action :authenticate_user!
    protect_from_forgery prepend: true
    
    #GET ext_logout
    #arriva un JWT in get, controllo il phpid. Redirect sul controller session per fare la logout facendo la delete delle sessioni
    #poi redirect su una ub che c'è in jwt 
    def ext_logout
      #se ho il jwt devo pulire la sessione salvata nel jwt
      unless http_get_token.blank?
          if phpid_ub_in_get_token?
            #cancello dalla sessione le chiavi
            session['phpid_da_cancellare'] = auth_get_token['phpid']
            session['ub_logout'] = auth_get_token['ub_logout']
            redirect_to :controller => "auth_hub/users/sessions", :action =>"ext_sign_out"
          else
            flash[:error] = "Non autorizzato: id sessione esterna mancante"
            redirect_to root_path
          end
      end
      return
    end
  
    #DA FARE
    def cambia_ente
  
    end
    
    private
  
    #metodo che estrae il token jwt da prametro in get
    def http_get_token
        @http_get_token ||= params['jwt'] if params['jwt'].present?
    end
    
    def auth_get_token
      @auth_get_token ||= JsonWebToken.decode(http_get_token)
    end
  
    def user_id_in_get_token?
      http_get_token && auth_get_token && auth_get_token[:idc]
    end
    
    def phpid_ub_in_get_token?
      http_get_token && auth_get_token && (!auth_get_token[:phpid].blank? && !auth_get_token[:ub_logout].blank?)
    end
    
    # # Uso di JWT con parametro in header, NON USATO
    # def http_token
    #     @http_token ||= if request.headers['Authorization'].present?
    #       request.headers['Authorization'].split(' ').last
    #     end
    # end
  
    # def auth_token
    #   @auth_token ||= JsonWebToken.decode(http_token)
    # end
  
    # def user_id_in_token?
    #   http_token && auth_token && auth_token[:idc]
    # end
  
  
    #Metodo che fa l'autenticazione
    def authenticate_user!
      if user_signed_in?
        enti_gestiti = @current_user.enti_gestiti
        @array_enti_gestiti = []
        @ente_principale = nil
        enti_gestiti.each do |ente|
          @ente_principale ||= ente.clienti_cliente.ID if ente.principale?
          array_ente_per_select_tag = [ente.clienti_cliente.CLIENTE, ente.clienti_cliente.ID] 
          @array_enti_gestiti << array_ente_per_select_tag
        end
        return true
      else
        #controllo se arrivo da form di login
        if request.post? and !params['user'].blank?
          @current_user = warden.authenticate!(:scope => :user)
          return true
        end
        #salvo l'url di provenienza per fare la redirect dopo l'autenticazione
        session[:url_pre_sign_in] = request.url if session[:auth].blank?
        redirect_to new_user_session_path, notice: "Please Login to view that page!"
      end
    end
        
    

    #helper per ricavare l'utente corrente loggato
    def current_user
      #carico l'user da sessione con auth esterna tramite omniauth
      @current_user ||= User.find_by(id: session['warden.user.user.key'][0][0]) unless session['warden.user.user.key'].blank?
      #se non ho fatto login esterna carico id salvato (usato in sign_in omniauth e anche login con email e psw devise)
      @current_user ||= User.find_by(id: session[:user_id])
      @current_user
    end
    
    
    def enti_gestiti
      if @current_user.nome_cognome == 'openweb'
        @enti_gestiti = "siena"
      else
        @enti_gestiti = "milano"
      end
      @enti_gestiti
    end
    
    
    #helper_method :current_user
    
    #dopo aver fatto la login con omniauth arrivo a questo metodo per capire dove fare il redirect
    #QUI PASSA SEMPRE
    def after_sign_in_path_for(user_instance)
      path = session[:url_pre_sign_in]
      #path = request.env['omniauth.origin'].blank? ? dashboard_url : request.env['omniauth.origin']
      #se ho settato questa variabile vengo da una app esterna, ripasso indietro dei parametri e faccio redirect
      if !session[:auth].blank? and !user_instance.jwt.blank?
        #headers['auth_token'] = user_instance.jwt
        path += "?jwt=#{user_instance.jwt}"
      end
      path
    end
    
    #dopo logout microsoft
    # def after_sign_out_path_for(user_instance)
    #   redirect_to root_path
    # end
    
    
   
   
  end
end
