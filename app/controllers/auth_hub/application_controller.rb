module AuthHub
  class ApplicationController < ActionController::Base
    before_action :authenticate_user!
    protect_from_forgery prepend: true
    
    #GET ext_logout
    def ext_logout
      redirect_to :controller => "auth_hub/users/sessions", :action =>"destroy", '_method' =>:delete
      return
    end
  
    #DA FARE
    def cambia_ente
  
    end
    
    private
  
    def authenticate_user!
        #se c'è il token con il parametro user_id sto facendo una richiesta con JWT
        begin  
            unless http_token.blank?
              session[:user_id] = @auth_token[:user_id]
              unless user_id_in_token?
                  flash[:error] = "Non autorizzato: user_id mancante"
                  #render json: { errors: ['Not Authenticated'] }, status: :unauthorized
                  return false
              end
              @current_user = User.find_by(id: auth_token[:user_id])
          
            else
              #NON HO JWT, DEVO AVER FATTO LOGIN AZURE
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
        rescue JWT::VerificationError, JWT::DecodeError => exc
            #render json: { errors: ['Not Authenticated'] }, status: :unauthorized
            flash[:error] = "Non autorizzato: #{exc.message}"
            return false
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
    def after_sign_in_path_for(user_instance)
      path = session[:url_pre_sign_in]
      #path = request.env['omniauth.origin'].blank? ? dashboard_url : request.env['omniauth.origin']
      #se ho settato questa variabile vengo da una app esterna, ripasso indietro dei parametri e faccio redirect
      if !session[:auth].blank? and !user_instance.jwt.blank?
        headers['auth_token'] = user_instance.jwt
        path += "?idc=#{session[:cliente_id]}&u=#{user_instance.email}"
      end
      path
    end
    
    #dopo logout microsoft
    # def after_sign_out_path_for(user_instance)
    #   redirect_to root_path
    # end
    
    def http_token
        @http_token ||= if request.headers['Authorization'].present?
          request.headers['Authorization'].split(' ').last
        end
    end
  
    def auth_token
      @auth_token ||= JsonWebToken.decode(http_token)
    end
  
    def user_id_in_token?
      http_token && auth_token && auth_token[:user_id].to_i
    end
   
   
  end
end
