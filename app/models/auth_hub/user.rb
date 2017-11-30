module AuthHub
  class User < ApplicationRecord
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :trackable, :validatable,
           :omniauthable, :omniauth_providers => [:azure_oauth2]
    
    #arriva un auth_hash del tipo
    # {
    #   uid: '12345',
    #   info: {
    #     name: 'some one',
    #     first_name: 'some',
    #     last_name: 'one',
    #     email: 'someone@example.com'
    #   },
    #   credentials: {
    #     token: 'thetoken',
    #     refresh_token: 'refresh'
    #   },
    #   extra: { raw_info: raw_api_response }
    # }
    
    
    def self.find_for_oauth(auth_hash)
      user = find_or_create_by(uid: auth_hash['uid'], provider: auth_hash['provider'])
      user.nome_cognome = auth_hash['info']['name']
      user.nome = auth_hash['info']['first_name']
      user.cognome = auth_hash['info']['last_name']
      user.email = auth_hash['info']['email']
      user.password = Devise.friendly_token[0,20]
      user.save!
      user
    end 
           
      
  
  end
end
