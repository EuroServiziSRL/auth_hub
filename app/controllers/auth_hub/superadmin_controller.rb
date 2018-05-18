require_dependency "auth_hub/application_controller"

module AuthHub
  class SuperadminController < ApplicationController
    
    #view con vari link
    def index
      @nome_pagina = "Home"
    end
  
  end
end
