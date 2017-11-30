module AuthHub
  class Users::SessionsController < Devise::SessionsController
    # before_action :configure_sign_in_params, only: [:create]
    skip_before_action :authenticate_user!, only: [:new]
    
  
    #GET /resource/sign_in
    def new
      self.resource = resource_class.new(sign_in_params)
      store_location_for(resource, params[:redirect_to])
      super
    end
  
    # POST /resource/sign_in
    # def create
    #   super
    # end
  
    # DELETE /resource/sign_out
    # def destroy
    #   super
    # end
  
    def destroy
      if current_user
        session.delete(:user_id)
        #cancello la sessione creata da devise
        session.delete('warden.user.user.key')
        flash[:success] = 'See you!'
      end
      redirect_to root_path
    end
  
  
    # protected
  
    # If you have extra params to permit, append them to the sanitizer.
    # def configure_sign_in_params
    #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
    # end
  end
end