module AuthHub
    class ClientiInstallazione < ClientiRecord
        self.table_name = 'clienti__installazione'
        self.primary_key = :ID
    
        has_many :clienti_applinstallate, class_name: 'AuthHub::ClientiApplinstallate', :foreign_key => "ID_INSTALLAZIONE"
        belongs_to :clienti_cliente, class_name: 'AuthHub::ClientiCliente'#, :foreign_key => "ID_ANAGRAFICA"
    
        scope :installazione_ruby, ->(id_cliente){ where(ID_ANAGRAFICA: id_cliente).where("SPIDERDB IS NOT NULL") }
    
        def installazione_ruby?
            return !self.SPIDERDB.blank?
        end
    end
end