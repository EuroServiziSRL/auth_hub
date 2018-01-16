AuthHub::Engine.routes.draw do
  
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
    
    
    devise_for :users, class_name: "AuthHub::User", module: "auth_hub", path: "/", 
    controllers: {
        sessions: 'auth_hub/users/sessions',
        omniauth_callbacks: 'auth_hub/users/omniauth_callbacks'
    }

    get 'dashboard' => 'dashboard#admin_dashboard', :as => :dashboard
    get '/' => 'dashboard#admin_dashboard', :as => :auth_hub_index
    get 'ext_logout' => 'application#ext_logout', :as => :external_logout

    post "cambia_ente" => "application#cambia_ente", :as => :cambia_ente

    root to: "dashboard#admin_dashboard"    
   
  
end
