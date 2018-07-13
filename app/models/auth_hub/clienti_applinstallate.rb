module AuthHub
    class ClientiApplinstallate < ClientiRecord
        self.table_name = 'clienti__applinstallate'
        self.primary_key = :ID
    
        belongs_to :installazione, class_name: 'ClientiInstallazione', :foreign_key => "ID_INSTALLAZIONE"
        
    end
end