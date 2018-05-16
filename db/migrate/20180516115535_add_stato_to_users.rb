class AddStatoToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :auth_hub_users, :stato, :string
  end
end
