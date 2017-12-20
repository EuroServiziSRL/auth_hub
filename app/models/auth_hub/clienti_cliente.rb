module AuthHub
    class ClientiCliente < ClientiRecord
        self.table_name = 'clienti__cliente'
        self.primary_key = :ID
    
    end
end