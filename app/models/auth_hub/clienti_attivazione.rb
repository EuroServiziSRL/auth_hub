module AuthHub
    class ClientiAttivazione < ClientiRecord
        self.table_name = 'clienti__attivazione'
        self.primary_key = :ID
        
        belongs_to :cliente, class_name: 'ClientiCliente', :foreign_key => "ID_CLIENTE"
        belongs_to :ordine, class_name: 'ClientiOrdine', :foreign_key => "ID_ORDINE"
        
        #metodo richiamato da gemma rails_admin
        def custom_label_method
            "#{self.CARTELLA}, #{self.SERVER}"
        end
    
    end
end