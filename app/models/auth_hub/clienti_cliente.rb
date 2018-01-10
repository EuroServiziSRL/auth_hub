module AuthHub
    class ClientiCliente < ClientiRecord
        self.table_name = 'clienti__cliente'
        self.primary_key = :ID
        
        #tabella per relazione N a N con gli user
        has_many :enti_gestiti
        has_many :users, through: :enti_gestiti
    end
end