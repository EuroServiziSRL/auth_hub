class AddWikiHdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :auth_hub_users, :wiki_hd, :boolean, :label => "Gestore Wiki HD"
  end
end
