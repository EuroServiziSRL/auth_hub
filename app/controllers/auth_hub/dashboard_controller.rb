require_dependency "auth_hub/application_controller"

#controller che contiene la logica per visualizzare i tasti delle app in base all'utente loggato

module AuthHub
  class DashboardController < ApplicationController
    before_action :authenticate_user!
    protect_from_forgery prepend: true
    
    #pagina per utente con ruolo user,
    #se admin viene fatto redirect
    def admin_dashboard
        if @current_user.superadmin_role
          path = index_superadmin_url
        elsif @current_user.admin_role
          path = index_admin_url
        elsif @current_user.admin_servizi
          path = index_admin_url
        end
        redirect_to path unless path.blank?
    end
    

    
    
  end
end
