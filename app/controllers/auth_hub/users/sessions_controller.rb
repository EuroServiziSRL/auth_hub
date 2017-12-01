module AuthHub
  class Users::SessionsController < Devise::SessionsController
    # before_action :configure_sign_in_params, only: [:create]
    skip_before_action :authenticate_user!, only: [:new, :destroy]
    
  
    #GET /resource/sign_in
    def new
      #leggo i parametri che arrivano e vedo se invocare subito il metodo per oauth2 azure
      #Azure active directory oauth2
      if params['auth'] == 'aad'
        session[:url_pre_sign_in] = params['ub']
        session[:cliente_id] = params['idc']
        session[:auth] = 'aad'
        redirect_to user_omniauth_azure_oauth2_authorize_path('azure_oauth2')
        return
      end
      # self.resource = resource_class.new(sign_in_params)
      # store_location_for(resource, params[:redirect_to])
      super
    end
  
    # POST /resource/sign_in
    # def create
    #   super
    # end
  
    # DELETE /resource/sign_out
    def destroy
      if current_user
        session.delete(:user_id)
        #cancello la sessione creata da devise
        session.delete('warden.user.user.key')
        session.delete(:url_pre_sign_in)
        flash[:success] = 'See you!'
      end
      redirect_to root_path
    end
  

    
    
  end
end