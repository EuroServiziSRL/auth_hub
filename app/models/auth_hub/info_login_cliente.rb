require 'jwe'
require 'zlib'

module AuthHub
    class InfoLoginCliente < ApplicationRecord

        CHIAVE = Rails.application.secrets.external_auth_api_key unless Rails.application.secrets.external_auth_api_key.blank?

        before_save :check_modifiche
        before_create :aggiungi_metadata

        # t.string  :org_name,            null: false
        # t.string  :org_display_name,    null: false
        # t.string  :org_url,             null: false
        # t.string  :key_path,            null: true
        # t.string  :cert_path,           null: true
        # t.boolean :app_ext,             null: true
        # t.string  :secret,              null: false
        # t.string  :client,              null: false
        # t.string  :url_app_ext,         null: true
        # t.string  :url_ass_cons_ext,    null: true
        # t.string  :url_metadata_ext,    null: true
        # t.string  :issuer,              null: false
        # t.boolean :spid,                null: true
        # t.boolean :spid_pre_prod,       null: true
        # t.boolean :cie,                 null: true
        # t.boolean :cie_pre_prod,        null: true
        # t.boolean :eidas,               null: true
        # t.boolean :eidas_pre_prod,      null: true
        # t.boolean :aggregato,           null: true
        # t.string  :cod_ipa_aggregato,   null: false
        # t.string  :p_iva_aggregato,     null: false
        # t.string  :cf_aggregato,        null: false
        # t.string  :stato_metadata,      null: false   aggiunto,modificato,cancellato, inviato(quando viene inviato ad agid assume questo stato)
        # t.belongs_to :clienti_cliente,  index: true,  optional: true
        
        mount_uploader :cert_path, CertUploader
        mount_uploader :key_path, PrivKeyUploader

        belongs_to :clienti_cliente, class_name: 'AuthHub::ClientiCliente'
        
        validates :issuer, :org_name, :org_display_name, :org_url, presence: true

        #se sono state fatte delle modifiche al record cambio lo stato e aggiorno la cache su auth
        #se non riesco ad aggiornare la cache su auth schedulare su una cosa l'aggiornamento
        def check_modifiche
            if self.changed?
                self.stato_metadata = 'modificato'
                #chiamo api per cancellare cache metadati
                #creo jwe
                priv_key = OpenSSL::PKey::RSA.new(File.read(Settings.path_key_jwe))
                payload = { 'client' => self.client }.to_json
                encrypted = JWE.encrypt(payload, priv_key, zip: 'DEF')
                response = HTTParty.get(File.join(Settings.app_auth_url,"spid/aggiorna_cache_metadata"),
                :headers => { 'Authorization' => "Bearer #{encrypted}" },
                :body => {},
                :follow_redirects => false,
                :timeout => 500 )
                unless response.blank?
                    if response['esito'] == 'ok'
                        logger.error "Cache aggiornata con successo!"
                    else
                        #TO-DO: schedulare su una coda l'aggiornamento della cache
                        logger.error "Cache non aggiornata!"
                    end                        
                else
                    #TO-DO: schedulare su una coda l'aggiornamento della cache
                    logger.error "Cache non aggiornata! Response vuota!"
                end
            end
        end

        def aggiungi_metadata
            self.stato_metadata = 'aggiunto'
        end

        def get_stato_manifest
            case self.stato_metadata
            when 'aggiunto'
                'POST'
            when 'modificato'
                'PUT'
            when 'cancellato'
                'DELETE'
            else
                'PUT' #se per errore lo inserisce nello zip lo metto come modificato
            end
        end

        
        def get_token_auth
            payload = {
                'start' => DateTime.now.new_offset(0).strftime("%d%m%Y%H%M%S")  #datetime in formato utc all'invio
            }    
            JWT.encode(payload, CHIAVE,'HS256')
        end

    end
end