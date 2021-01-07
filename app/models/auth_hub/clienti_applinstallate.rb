module AuthHub
    class ClientiApplinstallate < ClientiRecord
        self.table_name = 'clienti__applinstallate'
        self.primary_key = :ID
    
        belongs_to :installazione, class_name: 'ClientiInstallazione', :foreign_key => "ID_INSTALLAZIONE"
        #belongs_to :applicazione, class_name: 'ClientiApplicazione', :foreign_key => "APPLICAZIONE" non usare, la tabella php ha il nome e non l'id
        
    end
end