# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20140620123729) do

  create_table "accounts", force: true do |t|
    t.string   "name"
    t.string   "subdomain"
    t.integer  "owner_id"
    t.integer  "plan_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "rut"
    t.string   "address"
    t.string   "city"
    t.string   "phone"
    t.string   "country"
  end

  add_index "accounts", ["owner_id"], name: "index_accounts_on_owner_id", unique: true
  add_index "accounts", ["plan_id"], name: "index_accounts_on_plan_id"
  add_index "accounts", ["rut"], name: "index_accounts_on_rut"
  add_index "accounts", ["subdomain"], name: "index_accounts_on_subdomain"

  create_table "attachments", force: true do |t|
    t.string   "name"
    t.string   "category"
    t.integer  "attachable_id"
    t.string   "attachable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "resource_file_name"
    t.string   "resource_content_type"
    t.integer  "resource_file_size"
    t.datetime "resource_updated_at"
  end

  create_table "audits", force: true do |t|
    t.integer  "account_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "audits", ["account_id"], name: "index_audits_on_account_id"
  add_index "audits", ["user_id"], name: "index_audits_on_user_id"

  create_table "companies", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "rut"
    t.string   "address"
    t.string   "city"
    t.string   "province"
    t.string   "phone"
    t.string   "industry"
    t.integer  "account_id"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
  end

  add_index "companies", ["account_id"], name: "index_companies_on_account_id"
  add_index "companies", ["name"], name: "index_companies_on_name"
  add_index "companies", ["rut"], name: "index_companies_on_rut"

  create_table "contacts", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "phone"
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contacts", ["company_id"], name: "index_contacts_on_company_id"

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority"

  create_table "expenses", force: true do |t|
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "expenses", ["account_id"], name: "index_expenses_on_account_id"

  create_table "invoice_items", force: true do |t|
    t.integer  "account_id"
    t.integer  "quantity",    default: 0
    t.text     "description"
    t.integer  "price",       default: 0
    t.integer  "total",       default: 0
    t.integer  "invoice_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
  end

  add_index "invoice_items", ["account_id"], name: "index_invoice_items_on_account_id"
  add_index "invoice_items", ["invoice_id"], name: "index_invoice_items_on_invoice_id"
  add_index "invoice_items", ["type"], name: "index_invoice_items_on_type"

  create_table "invoices", force: true do |t|
    t.integer  "number"
    t.decimal  "tax_total",                default: 0.0
    t.decimal  "net_total",                default: 0.0
    t.decimal  "total",                    default: 0.0
    t.integer  "company_id"
    t.integer  "contact_id"
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "taxed"
    t.date     "due_date"
    t.date     "active_date"
    t.date     "close_date"
    t.string   "subject"
    t.integer  "tax_id"
    t.string   "tax_name"
    t.float    "tax_rate"
    t.string   "aasm_state",               default: "draft"
    t.string   "currency",                 default: "clp"
    t.integer  "due_days",                 default: 30
    t.float    "currency_convertion_rate", default: 1.0
    t.decimal  "original_currency_total",  default: 0.0
    t.decimal  "total_payed",              default: 0.0
  end

  add_index "invoices", ["aasm_state"], name: "index_invoices_on_aasm_state"
  add_index "invoices", ["account_id"], name: "index_invoices_on_account_id"
  add_index "invoices", ["company_id"], name: "index_invoices_on_company_id"
  add_index "invoices", ["contact_id"], name: "index_invoices_on_contact_id"
  add_index "invoices", ["currency"], name: "index_invoices_on_currency"
  add_index "invoices", ["tax_id"], name: "index_invoices_on_tax_id"

  create_table "plans", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reminders", force: true do |t|
    t.date     "notification_date"
    t.integer  "remindable_id"
    t.string   "remindable_type"
    t.boolean  "sent"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "notification_days"
    t.date     "due_date"
    t.string   "subject"
    t.text     "message"
    t.boolean  "active",            default: false
    t.text     "account_users_ids"
    t.text     "company_users_ids"
  end

  add_index "reminders", ["remindable_id"], name: "index_reminders_on_remindable_id"

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "account_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "last_name"
    t.boolean  "active"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
  end

  add_index "users", ["email", "account_id"], name: "index_users_on_email_and_account_id", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
