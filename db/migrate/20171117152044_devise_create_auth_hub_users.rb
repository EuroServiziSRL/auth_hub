class DeviseCreateAuthHubUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :auth_hub_users do |t|
      
      #campi provenienti da Azure Active Directory o inseriti da superadmin
      t.string :nome_cognome,     null: true
      t.string :nome,             null: true
      t.string :cognome,          null: true
      
      
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Confirmable
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at

      #Password expirable, gemma devise_security_extension
      t.datetime :password_changed_at

      t.timestamps null: false
    end

    add_index :auth_hub_users, :email,                unique: true
    add_index :auth_hub_users, :reset_password_token, unique: true
    # add_index :auth_hub_users, :confirmation_token,   unique: true
    # add_index :auth_hub_users, :unlock_token,         unique: true
    
    #aggiunto indice per gemma devise_security_extension
    add_index :auth_hub_users, :password_changed_at
    
    # Initialize first account:
    AuthHub::User.create! do |u|
        u.nome_cognome = "Super Admin"
        u.nome = "Admin"
        u.cognome = "ES"
        u.email     = 'test@test.it'
        u.password    = 'password'
    end
    
    
  end
end
