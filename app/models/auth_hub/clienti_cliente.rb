module AuthHub
    class ClientiCliente < ClientiRecord
        self.table_name = 'clienti__cliente'
        self.primary_key = :ID
        
        has_many :clienti_installazioni, class_name: 'ClientiInstallazione', :foreign_key => "ID_ANAGRAFICA"
        
        #tabella per relazione N a N con gli user
        has_many :enti_gestiti, inverse_of: 'clienti_cliente'
        has_many :users, through: :enti_gestiti
        
        
    end
end