class AddBelfioreToInfoLoginCliente < ActiveRecord::Migration[5.2]
  def change
    add_column :auth_hub_info_login_cliente, :belfiore_aggregato, :string, :null => false
  end
end
