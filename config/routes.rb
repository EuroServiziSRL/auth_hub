AuthHub::Engine.routes.draw do
  
  get 'superadmin/index'

    #devise_for :users, class_name: "AuthHub::User", path: "/", module: "auth_hub", 
    
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
    end
    
    
    #aggiungo la route per fare la logout esterna in get
    devise_scope :user do
      get 'ext_sign_out', :to => 'users/sessions#ext_sign_out', :as => :ext_sign_out
    end
    
    devise_for :users, class_name: "AuthHub::User", module: "auth_hub", path: "/",
    controllers: {
        sessions: 'auth_hub/users/sessions',
        omniauth_callbacks: 'auth_hub/users/omniauth_callbacks'
    }

    #path standard per crud degli enti_gestiti
    resources :enti_gestiti

    get 'enti_gestiti/:id/gestisci_applicazione_ente_gestito' => 'enti_gestiti#gestisci_applicazione_ente_gestito', :as => :gestisci_applicazione_ente_gestito

    #path standard per crud delle applicazioni associate all'ente
    resources :applicazioni_ente
    
    get 'users/:id/associa_enti' => 'users#associa_enti', :as => :associa_enti_user
    post 'users/:id/salva_enti_associati' => 'users#salva_enti_associati', :as => :salva_enti_associati
    get 'users/:id/cancella_enti/:ente' => 'users#cancella_enti', :as => :cancella_enti_user

    resources :users

    get 'dashboard' => 'dashboard#admin_dashboard', :as => :dashboard
    get '/' => 'dashboard#admin_dashboard', :as => :auth_hub_index
    get 'ext_logout' => 'application#ext_logout', :as => :external_logout
    
    post "cambia_ente" => "application#cambia_ente", :as => :cambia_ente

    get 'admin' => 'admin#index', :as => :index_admin
    get 'sa' => 'superadmin#index', :as => :index_superadmin

    root to: "dashboard#admin_dashboard"    
   
  
end
