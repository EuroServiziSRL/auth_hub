
require 'zlib'

module AuthHub
    class IoService < ApplicationRecord

        CHIAVE = Rails.application.secrets.external_auth_api_key unless Rails.application.secrets.external_auth_api_key.blank?

        before_save :check_modifiche

        # t.string :organization_name
        # t.string :department_name
        # t.string :organization_fiscal_code
        # t.string :service_name
        # t.string :service_id
        # t.string :primary_api_key
        # t.string :secondary_api_key
        # t.boolean :is_visible
        # t.boolean :require_secure_channels
        # t.longtext :description
        # t.string :web_url
        # t.string :app_ios
        # t.string :tos_url
        # t.string :privacy_url
        # t.string :address
        # t.string :phone
        # t.string :email
        # t.string :pec
        # t.string :cta
        # t.string :token_name
        # t.string :support_url
        # t.string :scope
        # t.string :authorized_cidrs
        # t.boolean :processato
        # t.boolean :da_inviare
        # t.boolean :inviato
        # t.boolean :logo_presente
        # t.belongs_to :clienti_cliente, index: true, optional: true
        # t.timestamps
        
       # mount_uploader :cert_path, CertUploader
       # mount_uploader :key_path, PrivKeyUploader

        belongs_to :clienti_cliente, class_name: 'AuthHub::ClientiCliente'
        
        #TO DO: campi obbligatori
        #validates :issuer, :org_name, :org_display_name, :org_url, :email_aggregato,  presence: true

        #se sono state fatte delle modifiche al record cambio lo stato e aggiorno la cache su auth
        #se non riesco ad aggiornare la cache su auth schedulare su una cosa l'aggiornamento
        def check_modifiche
            # if self.changed?
            #     self.stato_metadata = 'modificato'
            #     #chiamo api per cancellare cache metadati
            #     #creo jwe
            #     priv_key = OpenSSL::PKey::RSA.new(File.read(Settings.path_key_jwe))
            #     payload = { 'client' => self.client }.to_json
            #     encrypted = JWE.encrypt(payload, priv_key, zip: 'DEF')
            #     response = HTTParty.get(File.join(Settings.app_auth_url,"spid/aggiorna_cache_metadata"),
            #     :headers => { 'Authorization' => "Bearer #{encrypted}" },
            #     :body => {},
            #     :follow_redirects => false,
            #     :timeout => 500 )
            #     unless response.blank?
            #         if response['esito'] == 'ok'
            #             logger.error "Cache aggiornata con successo!"
            #         else
            #             #TO-DO: schedulare su una coda l'aggiornamento della cache
            #             logger.error "Cache non aggiornata!"
            #         end                        
            #     else
            #         #TO-DO: schedulare su una coda l'aggiornamento della cache
            #         logger.error "Cache non aggiornata! Response vuota!"
            #     end
            #end
        end

    end
end