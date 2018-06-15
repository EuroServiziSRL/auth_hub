module AuthHub
  class EnteGestito < ApplicationRecord
    belongs_to :clienti_cliente
    belongs_to :user
    
    has_many :applicazioni_ente
    
    
    scope :da_user, ->(id_user) { where(user: id_user) }
    scope :per_cliente, ->(id_cliente) { where(clienti_cliente: id_cliente) }
    scope :ente_principale_da_user, ->(id_user) { where(user: id_user, principale: true) }
    
    #cerca gli altri enti gestiti con stesso user e mette a false su principale
    def rendi_ente_principale(bool_val)
      if bool_val
        self.principale = true
        EnteGestito.da_user(self.user_id).each do |ente|
          ente.rendi_ente_principale(false) if ente.id != self.id 
        end
      else
        self.principale = false
      end
      self.save
    end
    
  end
end