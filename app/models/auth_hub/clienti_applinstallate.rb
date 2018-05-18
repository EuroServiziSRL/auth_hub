module AuthHub
    class ClientiApplinstallate < ClientiRecord
        self.table_name = 'clienti__applinstallate'
        self.primary_key = :ID
    
        belongs_to :clienti_applicazione, class_name: 'ClientiApplicazione', :foreign_key => "APPLICAZIONE"
    
    end
end