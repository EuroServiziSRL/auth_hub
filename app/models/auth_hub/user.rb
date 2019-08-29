module AuthHub
  class User < ApplicationRecord
    before_save :salva_nome_cognome
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :omniauthable, :password_expirable, :password_archivable, :omniauth_providers => [:azure_oauth2]

    
    filterrific(
      default_filter_params: {  },
      available_filters: [ :search_query ]
    )
           
    
    #tabella per relazione N a N, ha migration e model proprio
    has_many :enti_gestiti
    has_many :clienti_clienti, through: :enti_gestiti
    
    #fa la validazione della conferma password
    validates :nome, presence: { message: " è obbligatorio." }, on: [:registrazione_da_utente, :new_da_admin]
    validates :nome, format: { with: /.*/, message: "Caratteri non validi" }, allow_nil: true, on: [:update_da_admin]
    validates :cognome, presence: { message: " è obbligatorio." }, on: [:registrazione_da_utente, :new_da_admin]
    validates :cognome, format: { with: /.*/, message: "Caratteri non validi" }, allow_nil: true, on: [:update_da_admin]
    validates :email, uniqueness: { case_sensitive: false,  message: "già presente" },  presence: { message: " è obbligatoria." }
    validates_email_realness_of :email, on: :registrazione_da_utente, if: Proc.new { |obj| Rails.env.production? } #fa la validazione solo nel caso che sia una registrazione da nuovo utente admin e in prod
    validates :ente, presence: { message: " è obbligatorio." }, on: [:registrazione_da_utente]
    validates :telefono, presence: { message: " è obbligatorio." }, on: [:registrazione_da_utente]
    
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
      on: [:registrazione_da_utente,:aggiorna_password,:new_da_admin]
    
    validates :password, 
      allow_nil: true, 
      #length: { in: Devise.password_length, message: "La password deve contenere almeno 8 caratteri"}, 
      format: { with: PASSWORD_FORMAT, message: "deve contenere almeno 8 caratteri, una cifra e una maiuscola" }, 
      #confirmation: true, 
      on: [:new_da_admin,:aggiorna_password]
      
    validates :password, 
      allow_nil: true,  
      format: { with: PASSWORD_FORMAT, message: "deve contenere almeno 8 caratteri, una cifra e una maiuscola" },  
      on: [:update_da_admin],
      if: :password  #questo dice di fare la validazione solo nel caso in cui ci sia la password, in mod da admin se non la metto non faccio validaz
  

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
    
    #ritorna l'id per fare le query su tabella setup
    def sigla_ruolo
      if superadmin_role
        ["SU","AM","AS"]
      elsif admin_role
        ["AM","AS"]
      elsif admin_servizi
        ["AS"]
      else
        ["U"]
      end
    end
  
    #ritorna nil oppure il nome del cliente che ha quel dominio associato
    def trova_dominio_in_clienti(dominio)
      canonical_dominio = ApplicationController.helpers.to_canonical(dominio,false)
      logger.debug "\n\n Arriva chiamata da #{canonical_dominio}"
      trovato = nil
      unless self.enti_gestiti.blank?
        enti_gestiti.each{ |ente_corrente|
          if ente_corrente.clienti_cliente.clienti_installazioni.length > 0
            ente_corrente.clienti_cliente.clienti_installazioni.each{ |installazione|
                trovato = installazione.CLIENTE
                spider_url = ApplicationController.helpers.to_canonical(installazione.SPIDERURL,false)
                #qui ho l'installazione a livello di server che sarà o una ruby o php con le rispettive app
                dominio_installazione_ruby = spider_url || ( installazione.SPIDER_PORTAL.blank? ? "" : ApplicationController.helpers.to_canonical(installazione.SPIDER_PORTAL,false) ) 
                logger.debug "\n\n dominio inst ruby #{dominio_installazione_ruby}"
                canonical_dominio_installazione_ruby = ApplicationController.helpers.to_canonical(dominio_installazione_ruby,false) || ""
                logger.debug "\n\n dominio inst ruby canonico #{canonical_dominio_installazione_ruby}"
                dominio_installazione_hippo = installazione.HIPPO
                logger.debug "\n\n dominio inst hippo #{dominio_installazione_hippo}"
                canonical_dominio_installazione_hippo = ApplicationController.helpers.to_canonical(dominio_installazione_hippo,false) || ""
                logger.debug "\n\n dominio inst hippo canonico #{canonical_dominio_installazione_hippo}"
                #ritorno true se ci sono applicazioni installate riferite a questa installazione/server e se trovo lo stesso dominio 
                return trovato if installazione.clienti_applinstallate.length > 0 && ( !canonical_dominio_installazione_ruby.blank? && canonical_dominio_installazione_ruby.include?(canonical_dominio)) || (!canonical_dominio_installazione_hippo.blank? && canonical_dominio_installazione_hippo.include?(canonical_dominio))
            }                  
          end
        }
      end
      return trovato
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
  
    #metodo che crea e ritorna uno user all'accesso da azure
    def self.find_for_oauth(auth_hash)
      user = find_or_create_by(uid: auth_hash['uid'], provider: auth_hash['provider'])
      user.nome = auth_hash['info']['first_name']
      user.cognome = auth_hash['info']['last_name']
      nome_e_cognome = "#{user.nome} #{user.cognome}"
      user.nome_cognome = nome_e_cognome
      user.email = auth_hash['info']['email']
      user.password = Devise.friendly_token[0,20]
      user.stato = 'confermato'
      #inizializzo come un admin servizio
      user.admin_servizi = true
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
    
    #da usare per evitare scadenza password per utenti web service
    #def need_change_password?
    
    #end
    
    
    has_many :access_grants, class_name: "Doorkeeper::AccessGrant",
                           foreign_key: :resource_owner_id,
                           dependent: :delete_all # or :destroy if you need callbacks

    has_many :access_tokens, class_name: "Doorkeeper::AccessToken",
                           foreign_key: :resource_owner_id,
                           dependent: :delete_all # or :destroy if you need callbacks
    
    
  
  end
end
