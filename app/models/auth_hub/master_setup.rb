module AuthHub
    class MasterSetup < ClientiRecord
        self.table_name = 'master_setup'
        self.primary_key = :ID
        
        
        #metodo richiamato da gemma rails_admin
        def custom_label_method
            "#{self.APPLICAZIONE}.#{self.CODICE}"
        end
    
    end
end