module AuthHub
  class User < ApplicationRecord
    before_save :salva_nome_cognome
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :omniauthable, :password_expirable, :omniauth_providers => [:azure_oauth2]

    
    filterrific(
      default_filter_params: {  },
      available_filters: [ :search_query ]
    )
           
    
    #tabella per relazione N a N, ha migration e model proprio
    has_many :enti_gestiti
    has_many :clienti_clienti, through: :enti_gestiti
    
    #fa la validazione della conferma password
    validates :nome, presence: { message: " è obbligatorio." }
    validates :cognome, presence: { message: " è obbligatorio." }
    validates :email, uniqueness: { case_sensitive: false,  message: "già presente" },  presence: { message: " è obbligatoria." }
    validates_email_realness_of :email, on: :registrazione_da_utente, if: Proc.new { |obj| Rails.env.production? } #fa la validazione solo nel caso che sia una registrazione da nuovo utente admin e in prod
    
    
    #Usiamo la regola: almeno 8 caratteri, una cifra e una maiuscola
    PASSWORD_FORMAT = /\A
      (?=.{8,})          # Must contain 8 or more characters
      (?=.*\d)           # Must contain a digit
      (?=.*[A-Z])        # Must contain an upper case character
    /x
    
    #(?=.*[a-z])        # Must contain a lower case character
    #(?=.*[[:^alnum:]]) # Must contain a symbol
    
    validates :password, 
      presence: true, 
      #length: { in: Devise.password_length, message: "La password deve contenere almeno 8 caratteri" }, 
      format: { with: PASSWORD_FORMAT, message: "deve contenere almeno 8 caratteri, una cifra e una maiuscola" }, 
      confirmation: true, 
      on: :registrazione_da_utente
    
    validates :password, 
      allow_nil: true, 
      #length: { in: Devise.password_length, message: "La password deve contenere almeno 8 caratteri"}, 
      format: { with: PASSWORD_FORMAT, message: "deve contenere almeno 8 caratteri, una cifra e una maiuscola" }, 
      #confirmation: true, 
      on: :update_da_admin
  
    #nome_cognome lo creo dai campi separati
    def salva_nome_cognome
      self.nome_cognome = "#{self.nome} #{self.cognome}" if !self.nome.blank? && !self.cognome.blank?
    end
  
    def descrizione_ruolo
      if superadmin_role
        "Super Admin"
      elsif admin_role
        "Amministratore Portale"
      elsif admin_servizi
        "Amministratore Servizi"
      else
        "Utente"
      end
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
      user.nome = auth_hash['info']['first_name']
      user.cognome = auth_hash['info']['last_name']
      nome_e_cognome = "#{user.nome} #{user.cognome}"
      user.nome_cognome = nome_e_cognome
      user.email = auth_hash['info']['email']
      user.password = Devise.friendly_token[0,20]
      user.stato = 'confermato'
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
  
    scope :search_query, lambda { |query|
      return nil  if query.blank?
      # condition query, parse into individual keywords
      terms = query.downcase.split(/\s+/)
      # replace "*" with "%" for wildcard searches,
      # append '%', remove duplicate '%'s
      terms = terms.map { |e| ('%'+e.gsub('*', '%') + '%').gsub(/%+/, '%')}
          # configure number of OR conditions for provision
          # of interpolation arguments. Adjust this if you
          # change the number of OR conditions.
          num_or_conditions = 3
          where( terms.map {
        	  or_clauses = [
        	    "LOWER(nome) LIKE ?",
        	    "LOWER(cognome) LIKE ?",
        	    "LOWER(email) LIKE ?"
        	  ].join(' OR ')
        	  "(#{ or_clauses })"
        	}.join(' AND '),*terms.map { |e| [e] * num_or_conditions }.flatten)
      
    }
    
  
  end
end
