AuthHub::Engine.routes.draw do
  
  devise_for :users, class_name: "AuthHub::User"
end
