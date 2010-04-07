# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100325151534) do

  create_table "activities", :force => true do |t|
    t.text     "comments",                                  :null => false
    t.date     "date",                                      :null => false
    t.integer  "minutes",                                   :null => false
    t.integer  "project_id",                                :null => false
    t.integer  "user_id",                                   :null => false
    t.integer  "invoice_id"
    t.decimal  "price",       :precision => 8, :scale => 2
    t.integer  "currency_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "clients", :force => true do |t|
    t.string  "name",        :limit => 40,                    :null => false
    t.text    "description"
    t.string  "email",       :limit => 100
    t.boolean "active",                     :default => true, :null => false
  end

  create_table "currencies", :force => true do |t|
    t.string "singular_name", :null => false
    t.string "plural_name",   :null => false
    t.string "prefix"
    t.string "suffix"
  end

  add_index "currencies", ["singular_name"], :name => "index_currencies_on_singular_name", :unique => true

  create_table "free_days", :force => true do |t|
    t.date    "date",    :null => false
    t.integer "user_id", :null => false
  end

  add_index "free_days", ["date", "user_id"], :name => "main", :unique => true

  create_table "hourly_rate_logs", :force => true do |t|
    t.datetime "logged_at"
    t.string   "operation_type",                                    :null => false
    t.integer  "operation_author_id",                               :null => false
    t.integer  "hr_project_id"
    t.integer  "hr_role_id"
    t.date     "hr_takes_effect_at"
    t.decimal  "hr_value",            :precision => 8, :scale => 2
    t.integer  "hr_currency_id"
  end

  create_table "hourly_rates", :force => true do |t|
    t.integer "project_id",                                    :null => false
    t.integer "role_id",                                       :null => false
    t.date    "takes_effect_at",                               :null => false
    t.decimal "value",           :precision => 8, :scale => 2, :null => false
    t.integer "currency_id",                                   :null => false
  end

  add_index "hourly_rates", ["project_id", "role_id"], :name => "main", :unique => true

  create_table "invoices", :force => true do |t|
    t.string   "name",       :null => false
    t.text     "notes"
    t.integer  "user_id",    :null => false
    t.integer  "client_id",  :null => false
    t.datetime "issued_at"
    t.datetime "created_at"
  end

  create_table "projects", :force => true do |t|
    t.string   "name",        :null => false
    t.text     "description"
    t.integer  "client_id",   :null => false
    t.boolean  "active",      :null => false
    t.datetime "created_at"
  end

  create_table "roles", :force => true do |t|
    t.string  "name",                      :limit => 40, :null => false
    t.boolean "can_manage_financial_data",               :null => false
  end

  add_index "roles", ["name"], :name => "index_roles_on_name", :unique => true

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "settings", :force => true do |t|
    t.boolean "enable_notifications", :null => false
    t.string  "free_days_access_key", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 40,                    :null => false
    t.string   "name",                      :limit => 100,                   :null => false
    t.string   "email",                     :limit => 100,                   :null => false
    t.string   "crypted_password",          :limit => 40,                    :null => false
    t.string   "salt",                      :limit => 40,                    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.boolean  "active",                                   :default => true, :null => false
    t.boolean  "admin"
    t.integer  "role_id"
    t.integer  "client_id"
    t.string   "login_key"
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

end
