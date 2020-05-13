module AuthHub
    class InfoLoginCliente < ApplicationRecord
        before_save :check_modifiche
        before_create :aggiungi_metadata

        # t.string  :key_path,            null: false
        # t.string  :cert_path,           null: false
        # t.boolean :app_ext,             null: true
        # t.string  :secret,              null: false
        # t.string  :client,              null: false
        # t.string  :url_app_ext,         null: true
        # t.string  :url_ass_cons_ext,    null: true
        # t.string  :issuer,              null: false
        # t.string  :org_name,            null: false
        # t.string  :org_display_name,    null: false
        # t.string  :org_url,             null: false
        # t.boolean :spid,                null: true
        # t.boolean :spid_pre_prod,       null: true
        # t.boolean :cie,                 null: true
        # t.boolean :cie_pre_prod,        null: true
        # t.boolean :eidas,               null: true
        # t.boolean :eidas_pre_prod,      null: true
        # t.boolean :aggregato,           null: true
        # t.string  :stato_metadata,      null: false   aggiunto,modificato,cancellato, inviato(quando viene inviato ad agid assume questo stato)
        # t.belongs_to :clienti_cliente,  index: true,  optional: true
        
        mount_uploader :cert_path, CertUploader
        mount_uploader :key_path, PrivKeyUploader

        belongs_to :clienti_cliente, class_name: 'AuthHub::ClientiCliente'
        
        validates :issuer, :org_name, :org_display_name, :org_url, presence: true

        def check_modifiche
            if self.changed?
                self.stato_metadata = 'modificato'
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


    end
end