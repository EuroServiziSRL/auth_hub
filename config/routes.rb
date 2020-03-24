AuthHub::Engine.routes.draw do
    
  use_doorkeeper
    #nella route mostra doppio auth_hub ma funziona!
    
    #Sistema le route togliendo l'engine davanti
    devise_scope :user do
      providers = Regexp.union(Devise.omniauth_providers.map(&:to_s))
      path_prefix = ''
    
      match "#{path_prefix}/:provider",
        :constraints => { :provider => providers },
        :to => "/auth_hub/users/omniauth_callbacks#passthru",
        :as => :user_omniauth_azure_oauth2_authorize,
        :via => [:get, :post]
    
      match "#{path_prefix}/:action/callback",
        :constraints => { :action => providers },
        :to => "/auth_hub/users/omniauth_callbacks#azure_oauth2",
        :as => :user_omniauth_azure_oauth2_callback,
        :via => [:get, :post]
      
      #aggiungo la route per fare la logout esterna in get e la registrazione in post
      get 'ext_sign_out', :to => 'users/sessions#ext_sign_out', :as => :ext_sign_out
      #post 'salva_utente', :to => 'users/registrations#create', :as => :salva_utente  
      
    end
    
    devise_for :users, class_name: "AuthHub::User", module: "auth_hub", path: "/",
    controllers: {
        sessions: 'auth_hub/users/sessions',
        omniauth_callbacks: 'auth_hub/users/omniauth_callbacks',
        registrations: 'auth_hub/users/registrations',
        password_expired: 'auth_hub/users/password_expired'
    }

    get 'users/:id/associa_enti' => 'users#associa_enti', :as => :associa_enti_user
    post 'users/:id/salva_enti_associati' => 'users#salva_enti_associati', :as => :salva_enti_associati
    get 'users/:id/cancella_enti/:ente' => 'users#cancella_enti', :as => :cancella_enti_user
    get 'users/utenti_da_confermare' => 'users#utenti_da_confermare', :as => :utenti_da_confermare
    get 'users/utenti_servizi' => 'users#utenti_servizi', :as => :utenti_servizi

    resources :users

    #path standard per crud degli enti_gestiti
    resources :enti_gestiti

    get 'enti_gestiti/:id/vedi_applicazione_ente_gestito' => 'enti_gestiti#vedi_applicazione_ente_gestito', :as => :vedi_applicazione_ente_gestito
    get 'enti_gestiti/:id/rendi_ente_principale' => 'enti_gestiti#rendi_ente_principale', :as => :rendi_ente_principale

    #path standard per crud delle applicazioni associate all'ente
    resources :applicazioni_ente
    

    get 'dashboard' => 'application#user_dashboard', :as => :dashboard
    get '/' => 'application#user_dashboard', :as => :auth_hub_index
    get 'ext_logout' => 'application#ext_logout', :as => :external_logout
    post "cambia_ente" => "application#cambia_ente", :as => :cambia_ente
    get 'aggiorna_clienti' => 'application#aggiorna_clienti', :as => :aggiorna_clienti, :defaults => { :format => 'json' }
    
    get 'cambia_password_admin' => 'application#cambia_password_admin', :as => :cambia_password_admin
    post 'aggiorna_password' => 'application#aggiorna_password', :as => :aggiorna_password
    
    get 'sa' => 'superadmin#index', :as => :index_superadmin
    get 'admin' => 'admin#index', :as => :index_admin
  
    resources :setups
  
end
