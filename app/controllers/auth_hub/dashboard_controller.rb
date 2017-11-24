require_dependency "auth_hub/application_controller"

module AuthHub
  class DashboardController < ApplicationController
    before_action :authenticate_user!
    
    def admin_dashboard
      debugger
      a=4
    end
    
    
    
    
  end
end
