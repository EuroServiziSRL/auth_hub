class CreateInfoLoginCliente < ActiveRecord::Migration[5.2]
  def change
    create_table :auth_hub_info_login_cliente do |t|
      t.string  :org_name,            null: false
      t.string  :org_display_name,    null: false
      t.string  :org_url,             null: false
      t.string  :key_path,            null: true
      t.string  :cert_path,           null: true
      t.boolean :app_ext,             null: true
      t.string  :secret,              null: false
      t.string  :client,              null: false
      t.string  :url_app_ext,         null: true
      t.string  :url_ass_cons_ext,    null: true
      t.string  :url_metadata_ext,    null: true
      t.string  :issuer,              null: false
      t.boolean :spid,                null: true
      t.boolean :spid_pre_prod,       null: true
      t.boolean :cie,                 null: true
      t.boolean :cie_pre_prod,        null: true
      t.boolean :eidas,               null: true
      t.boolean :eidas_pre_prod,      null: true
      t.boolean :aggregato,           null: true
      t.string  :cod_ipa_aggregato,   null: false
      t.string  :p_iva_aggregato,     null: false
      t.string  :cf_aggregato,        null: false
      t.string  :stato_metadata,      null: false
      t.belongs_to :clienti_cliente,  index: true,  optional: true
    end
  end
end
