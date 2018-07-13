#PER ORA NON UTILIZZATA
module AuthHub
  class ApplicazioniEnte < ApplicationRecord
    belongs_to :ente_gestito
    belongs_to :clienti_applicazione
    
    scope :dell_ente, ->(id_ente) { where(ente_gestito: id_ente) }
    scope :enti_con_applicazione, ->(id_applicazione) { where(clienti_applicazione: id_applicazione) }
    
    
  end
end