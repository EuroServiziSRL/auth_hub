class AddRolesToAuthHubUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :auth_hub_users, :superadmin_role, :boolean, default: false
    add_column :auth_hub_users, :admin_role, :boolean, default: false
    add_column :auth_hub_users, :admin_servizi, :boolean, default: false
    add_column :auth_hub_users, :user_role, :boolean, default: true
  end
end
