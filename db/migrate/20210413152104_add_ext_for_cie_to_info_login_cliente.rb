class AddExtForCieToInfoLoginCliente < ActiveRecord::Migration[5.2]
  def change
    add_column :auth_hub_info_login_cliente, :url_ass_cons_ext_cie, :string, :null => true
    add_column :auth_hub_info_login_cliente, :url_metadata_ext_cie, :string, :null => true
  end
end
