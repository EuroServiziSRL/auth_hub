class CreateIoServices < ActiveRecord::Migration[5.2]
  def change
    create_table :io_services do |t|
      t.string :organization_name
      t.string :department_name
      t.string :organization_fiscal_code
      t.string :service_name
      t.string :service_id
      t.string :primary_api_key
      t.string :secondary_api_key
      t.boolean :is_visible
      t.boolean :require_secure_channels
      t.longtext :description
      t.string :web_url
      t.string :app_ios
      t.string :tos_url
      t.string :privacy_url
      t.string :address
      t.string :phone
      t.string :email
      t.string :pec
      t.string :cta
      t.string :token_name
      t.string :support_url
      t.string :scope
      t.string :authorized_cidrs
      t.boolean :processato
      t.boolean :da_inviare
      t.boolean :inviato
      t.boolean :logo_presente
      t.belongs_to :clienti_cliente, index: true, optional: true
      t.timestamps
    end
  end
end
