AuthHub::Engine.routes.draw do
  
    #devise_for :users, class_name: "AuthHub::User", path: "/", module: "auth_hub", 
    
    #nella route mostra doppio auth_hub ma funziona!
    
    #Sistema le route togliendo l'engine davanti
    devise_scope :user do
      providers = Regexp.union(Devise.omniauth_providers.map(&:to_s))
      path_prefix = ''
    
      match "#{path_prefix}/:provider",
        :constraints => { :provider => providers },
        :to => "/users/omniauth_callbacks#passthru",
        :as => :user_omniauth_authorize,
        :via => [:get, :post]
    
      match "#{path_prefix}/:action/callback",
        :constraints => { :action => providers },
        :to => "/users/omniauth_callbacks#azure_oauth2",
        :as => :user_omniauth_callback,
        :via => [:get, :post]
    end
    
    
    devise_for :users, class_name: "AuthHub::User", module: "auth_hub", path: "/", 
    controllers: {
        sessions: 'users/sessions',
        omniauth_callbacks: 'users/omniauth_callbacks'
    }

    get 'dashboard' => 'dashboard#admin_dashboard', :as => :dashboard

    
    # devise_scope :user do
    #     get '/users/auth/azureoauth2' => '/users/omniauth_callbacks#passthru'
    # end
    
    # as :user do
    #     get 'users/sign_in' => 'sessions#new', :as => :new_user_session
    #     post 'users/sign_in' => 'sessions#create', :as => :user_session
    #     get 'users/sign_out' => 'sessions#destroy', :as => :destroy_user_session
    # end
  
    # scope "auth_hub" do
    #     get '/users/sessions/new', to: 'users/sessions#new'
    # end
  
end
