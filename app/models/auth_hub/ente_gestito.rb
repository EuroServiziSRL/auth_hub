module AuthHub
  class EnteGestito < ApplicationRecord
    belongs_to :clienti_cliente
    belongs_to :user
    
    has_many :applicazioni_ente
    
    
    scope :da_user, ->(id_user) { where(user: id_user) }
    scope :per_cliente, ->(id_cliente) { where(clienti_cliente: id_cliente) }
    
    
  end
end