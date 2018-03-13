module AuthHub
  class User < ApplicationRecord
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:azure_oauth2]
           
    
    #tabella per relazione N a N, ha migration e model proprio
    has_many :enti_gestiti
    has_many :clienti_clienti, through: :enti_gestiti
    
    #fa la validazione della conferma password
    validates_confirmation_of :password
    
    #nome_cognome lo creo dai campi separati
    def nome_cognome=(valore)
      super("#{nome} #{cognome}") 
    end
  
    #Log dell'accesso dopo autenticazione
    Warden::Manager.after_authentication do |user, auth, opts|
      ::AccessLog.debug("User #{user.nome} #{user.cognome}, #{user.email} (id: #{user.id}) login at #{DateTime.now} from #{user.current_sign_in_ip}. Superadmin: #{user.superadmin_role}, Admin: #{user.admin_role}, Admin Servizio: #{user.admin_servizi}")
    end
   
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
      #aggiorno la lista dei clienti associati in base al tenant id
      #parametri microsoft in request.env['omniauth.auth']['info']['tid']
      #cerco i clienti con tenant id uguale a quello dello user appena autenticato
      tenant_id = auth_hash['info']['tid']
      #controllo se ha il cliente associato
      #clienti_tenant_associato = ClientiCliente.find_by_tenant_azure(tenant_id)
      ClientiCliente.where(tenant_azure: tenant_id).find_each do |cliente|
        #se non ho associazioni
        if user.enti_gestiti.blank?
          user.enti_gestiti.create(clienti_cliente: cliente)
        else
          #controllo se presente nell'associazione enti_gestiti
          trovato = user.enti_gestiti.per_cliente(cliente.id)
          if trovato.blank?
            user.enti_gestiti.create(clienti_cliente: cliente)
          end
        end
        user.save!
      end
    
      user
    end 
      
  
  end
end
