class CreateApplicazioniEnte < ActiveRecord::Migration[5.1]
  def change
    create_table :auth_hub_applicazioni_ente do |t|
      t.belongs_to :ente_gestito, index: true
      t.belongs_to :clienti__applicazione, index: true
    end
  end
end
