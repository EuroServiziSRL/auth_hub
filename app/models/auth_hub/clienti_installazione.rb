module AuthHub
    class ClientiInstallazione < ClientiRecord
        self.table_name = 'clienti__installazione'
        self.primary_key = :ID
    
        has_many :clienti_applinstallate, class_name: 'ClientiApplinstallate', :foreign_key => "ID_INSTALLAZIONE"
    
    end
end