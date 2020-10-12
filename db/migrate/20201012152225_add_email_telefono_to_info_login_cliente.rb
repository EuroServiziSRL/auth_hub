class AddEmailTelefonoToInfoLoginCliente < ActiveRecord::Migration[5.2]
  def change
    add_column :auth_hub_info_login_cliente, :email_aggregato, :string, :null => false
    add_column :auth_hub_info_login_cliente, :telefono_aggregato, :string
  end
end
