Rails.application.routes.draw do
  mount AuthHub::Engine => "/auth_hub"
end
