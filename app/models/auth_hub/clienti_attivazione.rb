module AuthHub
    class ClientiAttivazione < ClientiRecord
        self.table_name = 'clienti__attivazione'
        self.primary_key = :ID
    
    end
end