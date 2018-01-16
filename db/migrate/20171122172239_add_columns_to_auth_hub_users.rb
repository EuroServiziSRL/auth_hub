class AddColumnsToAuthHubUsers < ActiveRecord::Migration[5.1]
  def change
    #colonne per Azure
    add_column :auth_hub_users, :provider, :string
    add_column :auth_hub_users, :uid, :string
    #colonne per jwt, auth da app esterna
    add_column :auth_hub_users, :jwt, :text
    add_column :auth_hub_users, :jwt_created, :datetime
  end
end
