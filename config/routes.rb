AuthHub::Engine.routes.draw do
  
    
    devise_for :users, class_name: "AuthHub::User", module: "auth_hub", 
    controllers: {
        sessions: 'users/sessions'
    }
    
    # as :user do
    #     get 'users/sign_in' => 'sessions#new', :as => :new_user_session
    #     post 'users/sign_in' => 'sessions#create', :as => :user_session
    #     get 'users/sign_out' => 'sessions#destroy', :as => :destroy_user_session
    # end
  
    # scope "auth_hub" do
    #     get '/users/sessions/new', to: 'users/sessions#new'
    # end
  
end
