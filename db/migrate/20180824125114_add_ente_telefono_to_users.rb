class AddEnteTelefonoToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :auth_hub_users, :ente, :string
    add_column :auth_hub_users, :telefono, :string
  end
end
