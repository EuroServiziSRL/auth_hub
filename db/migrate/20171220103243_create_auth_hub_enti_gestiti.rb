class CreateAuthHubEntiGestiti < ActiveRecord::Migration[5.1]
  def change
    create_table :auth_hub_enti_gestiti do |t|
      t.belongs_to :user, index: true
      t.belongs_to :clienti_cliente, index: true
    end
  end
end
