class AddColumnsToAuthHubUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :auth_hub_users, :provider, :string
    add_column :auth_hub_users, :uid, :string
  end
end
