module AuthHub
    class ClientiApplicazione < ClientiRecord
        self.table_name = 'clienti__applicazione'
        self.primary_key = :ID
    
        has_many :applicazioni_ente
    
    end
end
