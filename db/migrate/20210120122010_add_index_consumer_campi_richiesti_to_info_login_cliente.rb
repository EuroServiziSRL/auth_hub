class AddIndexConsumerCampiRichiestiToInfoLoginCliente < ActiveRecord::Migration[5.2]
  def change
    add_column :auth_hub_info_login_cliente, :index_consumer, :string
    add_column :auth_hub_info_login_cliente, :campi_richiesti, :string
  end
end
