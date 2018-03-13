# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180313104839) do

  create_table "applicazioni_entes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "ente_gestito_id"
    t.bigint "clienti__applicazione_id"
    t.index ["clienti__applicazione_id"], name: "index_applicazioni_entes_on_clienti__applicazione_id"
    t.index ["ente_gestito_id"], name: "index_applicazioni_entes_on_ente_gestito_id"
  end

  create_table "auth_hub_enti_gestiti", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.boolean "principale"
    t.bigint "user_id"
    t.bigint "clienti_cliente_id"
    t.index ["clienti_cliente_id"], name: "index_auth_hub_enti_gestiti_on_clienti_cliente_id"
    t.index ["user_id"], name: "index_auth_hub_enti_gestiti_on_user_id"
  end

  create_table "auth_hub_users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "nome_cognome"
    t.string "nome"
    t.string "cognome"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "password_changed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "superadmin_role", default: false
    t.boolean "admin_role", default: false
    t.boolean "admin_servizi", default: false
    t.boolean "user_role", default: true
    t.string "provider"
    t.string "uid"
    t.text "jwt"
    t.datetime "jwt_created"
    t.index ["email"], name: "index_auth_hub_users_on_email", unique: true
    t.index ["password_changed_at"], name: "index_auth_hub_users_on_password_changed_at"
    t.index ["reset_password_token"], name: "index_auth_hub_users_on_reset_password_token", unique: true
  end

end
